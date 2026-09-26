from django.db.models import F
from django.contrib import messages
from django.contrib.auth import login
from django.contrib.auth.views import LoginView, LogoutView
from django.core.cache import cache
from django.core.paginator import Paginator
from django.utils.translation import gettext
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_POST

from django.db.models import Count
from django.db.models import Q

from .forms import CommentForm
from .models import Category, Comment, Post, SiteSetting, Tag, Vote


def sidebar_context():
    """列表、详情和筛选页共用一组侧边栏查询。"""

    archives = (
        Post.published
        .filter(published_at__isnull=False)
        .values("published_at__year", "published_at__month")
        .annotate(total=Count("id"))
        .order_by("-published_at__year", "-published_at__month")
    )
    return {
        "latest_posts": list(Post.published.all()[:5]),
        "popular_posts": list(Post.published.order_by("-views")[:5]),
        "recent_comments": list(Comment.objects.select_related("post")[:5]),
        "sidebar_categories": list(Category.objects.annotate(total=Count("posts")).filter(total__gt=0)),
        "archives": archives,
    }


def cached_sidebar_context():
    """侧边栏查询结果缓存一分钟；Redis URL 存在时自动使用 Redis。"""

    return cache.get_or_set("blog:sidebar:v1", sidebar_context, timeout=60)


def post_list(request):
    posts = Post.published.select_related("category").prefetch_related("tags")
    query = request.GET.get("q", "").strip()
    if query:
        posts = posts.filter(
            Q(title__icontains=query)
            | Q(summary__icontains=query)
            | Q(body__icontains=query)
        )
    return render(request, "blog/post_list.html", {
        **cached_sidebar_context(),
        "page_obj": paginate_posts(request, posts),
        "query": query,
    })


def paginate_posts(request, posts):
    """所有文章列表共用后台设置的页大小。"""

    page_size = SiteSetting.load().page_size
    return Paginator(posts, page_size).get_page(request.GET.get("page"))


def post_detail(request, pk):
    post = get_object_or_404(
        Post.published.select_related("category").prefetch_related("tags"),
        pk=pk,
    )
    # 只更新浏览量，避免并发访问把旧值写回去。
    Post.objects.filter(pk=pk).update(views=F("views") + 1)
    post.refresh_from_db(fields=["views"])
    return render(request, "blog/post_detail.html", {**sidebar_context(), "post": post})


def category_posts(request, slug):
    category = get_object_or_404(Category, slug=slug)
    posts = Post.published.filter(category=category).select_related("category").prefetch_related("tags")
    return render(request, "blog/post_list.html", {
        **cached_sidebar_context(),
        "page_obj": paginate_posts(request, posts),
        "page_title": gettext("分类：%(category)s") % {"category": category},
    })


def tag_posts(request, slug):
    tag = get_object_or_404(Tag, slug=slug)
    posts = Post.published.filter(tags=tag).select_related("category").prefetch_related("tags")
    return render(request, "blog/post_list.html", {
        **cached_sidebar_context(),
        "page_obj": paginate_posts(request, posts),
        "page_title": gettext("标签：%(tag)s") % {"tag": tag},
    })


def archive_posts(request, year, month):
    posts = Post.published.filter(
        published_at__year=year,
        published_at__month=month,
    ).select_related("category").prefetch_related("tags")
    return render(request, "blog/post_list.html", {
        **cached_sidebar_context(),
        "page_obj": paginate_posts(request, posts),
        "page_title": gettext("%(year)s 年 %(month)s 月归档") % {"year": year, "month": month},
    })


def tag_cloud(request):
    tags = Tag.objects.annotate(total=Count("posts")).filter(total__gt=0)
    max_count = max((tag.total for tag in tags), default=1)
    for tag in tags:
        # 文章数映射到 100% 至 160%，有层次但不破坏排版。
        tag.font_size = 100 + int(60 * tag.total / max_count)
    return render(request, "blog/tag_cloud.html", {
        **cached_sidebar_context(),
        "tags": tags,
    })


def add_comment(request, pk):
    post = get_object_or_404(Post.published, pk=pk)
    form = CommentForm(request.POST)
    if form.is_valid():
        comment = form.save(commit=False)
        comment.post = post
        comment.save()
        messages.success(request, gettext("评论已提交。"))
    else:
        messages.error(request, gettext("请检查昵称、邮箱和评论内容。"))
    return redirect(post)


def register(request):
    from .forms import UserRegistrationForm

    if request.user.is_authenticated:
        return redirect("blog:list")
    form = UserRegistrationForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        user = form.save()
        login(request, user)
        messages.success(request, gettext("注册成功，欢迎加入。"))
        return redirect("blog:list")
    return render(request, "registration/register.html", {"form": form})


class BlogLoginView(LoginView):
    template_name = "registration/login.html"


class BlogLogoutView(LogoutView):
    pass


@require_POST
def vote(request, pk, value):
    vote_value = 1 if value == 1 else -1
    post = get_object_or_404(Post.published, pk=pk)
    if value not in (1, -1):
        return redirect(post)
    if not request.session.session_key:
        request.session.create()

    _, created = Vote.objects.get_or_create(
        post=post,
        session_key=request.session.session_key,
        defaults={"value": vote_value},
    )
    if not created:
        messages.info(request, gettext("你已经对这篇文章投过票了。"))
        return redirect(post)

    if vote_value == 1:
        Post.objects.filter(pk=pk).update(likes=F("likes") + 1)
    else:
        Post.objects.filter(pk=pk).update(dislikes=F("dislikes") + 1)
    messages.success(request, gettext("感谢你的反馈。"))
    return redirect(post)
