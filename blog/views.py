# coding=utf-8
from .models import Post, Comment, Tag, Category, Evaluate, Page
from .commons import cache_manager
from django.shortcuts import render, get_object_or_404
from .forms import PostForm, CommentForm
from django.core.urlresolvers import reverse
from django.shortcuts import redirect
from django.contrib.auth.decorators import login_required
from django.db.models import Count
from datetime import datetime, timedelta
from django.http import Http404
from django.http import HttpResponse
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
import json


from haystack.forms import SearchForm
# import qiniu


def full_search(request):
    """全局搜索"""
    keywords = request.GET['q']
    sform = SearchForm(request.GET)
    posts = sform.search()
    return render(request, 'blog/post_search_list.html',
                  {'posts': posts, 'list_header': '关键字 \'{}\' 搜索结果'.format(keywords)})


def get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def post_list(request):
    """所有已发布文章"""
    postsAll = Post.objects.annotate(num_comment=Count('comment')).filter(
        published_date__isnull=False).prefetch_related(
        'category').prefetch_related('tags').order_by('-published_date')
    for p in postsAll:
        p.click = cache_manager.get_click(p)
    paginator = Paginator(postsAll, 10)  # Show 10 contacts per page
    page = request.GET.get('page')
    try:
        posts = paginator.page(page)
    except PageNotAnInteger:
        # If page is not an integer, deliver first page.
        posts = paginator.page(1)
    except EmptyPage:
        # If page is out of range (e.g. 9999), deliver last page of results.
        posts = paginator.page(paginator.num_pages)
    return render(request, 'blog/post_list.html', {'posts': posts, 'page': True})


def post_list_by_tag(request, tag):
    """根据标签列出已发布文章"""
    posts = Post.objects.annotate(num_comment=Count('comment')).filter(
        published_date__isnull=False, tags__name=tag).prefetch_related(
        'category').prefetch_related('tags').order_by('-published_date')
    for p in posts:
        p.click = cache_manager.get_click(p)
    return render(request, 'blog/post_list.html',
                  {'posts': posts, 'list_header': '文章标签 \'{}\''.format(tag)})


def post_list_by_category(request, cg):
    """根据目录列表已发布文章"""
    posts = Post.objects.annotate(num_comment=Count('comment')).filter(
        published_date__isnull=False, category__name=cg).prefetch_related(
        'category').prefetch_related('tags').order_by('-published_date')
    for p in posts:
        p.click = cache_manager.get_click(p)
    return render(request, 'blog/post_list.html',
                  {'posts': posts, 'list_header': '\'{}\' 分类的存档'.format(cg)})


def post_list_by_ym(request, y, m):
    """根据年月份列出已发布文章"""
    posts = Post.objects.annotate(num_comment=Count('comment')).filter(
        published_date__isnull=False, published_date__year=y,
        published_date__month=m).prefetch_related(
        'category').prefetch_related('tags').order_by('-published_date')
    for p in posts:
        p.click = cache_manager.get_click(p)
    return render(request, 'blog/post_list.html',
                  {'posts': posts, 'list_header': '{0}年{1}月 的存档'.format(y, m)})


def post_detail(request, pk):
    try:
        post = Post.objects.extra(
            select={
                "good": """
                SELECT COUNT(*)
                FROM blog_evaluate
                WHERE evaluate=1 and post_id={0}
                """.format(pk),
                "bad": """
                SELECT COUNT(*)
                FROM blog_evaluate
                WHERE evaluate=0 and post_id={0}
                """.format(pk),
                "ip_count": """
                SELECT COUNT(*)
                FROM blog_evaluate
                WHERE ip='{0}' and post_id={1}
                """.format(get_client_ip(request), pk),
            }
        ).get(pk=pk)
    except:
        raise Http404()
    if post.published_date:
        cache_manager.update_click(post)
        post.click = cache_manager.get_click(post)
    form = CommentForm()
    post.text = post.text.replace('[!--more--]', '', 1)
    return render(request, 'blog/post_detail.html',
                  {'post': post, 'form': form, 'comments': post.comment_set.all()})


def page_detail(request, pk):
    try:
        page = Page.objects.get(pk=pk)
    except:
        raise Http404()
    return render(request, 'blog/page_detail.html', {'page': page})


def evaluate(request, pk, ev):
    """顶：1  踩：0"""
    client_ip = get_client_ip(request)
    if Evaluate.objects.filter(ip=client_ip, post__id=pk).count() > 0:
        raise Http404()
    ev_model = Evaluate(ip=client_ip, evaluate=ev, post_id=pk)
    ev_model.save()
    p = Post.objects.extra(
        select={
            "good": """
                SELECT COUNT(*)
                FROM blog_evaluate
                WHERE evaluate=1 and post_id={0}
                """.format(pk),
            "bad": """
                SELECT COUNT(*)
                FROM blog_evaluate
                WHERE evaluate=0 and post_id={0}
                """.format(pk),
        }
    ).get(pk=pk)
    return HttpResponse(json.dumps(
        {'success': True, 'good': p.good, 'bad': p.bad}), content_type="application/json")


def add_comment(request, pk):
    """添加评论"""
    form = CommentForm(request.POST)
    if form.is_valid():
        comment = form.save(commit=False)
        comment.post_id = pk
        comment.save()
        return redirect('blog.views.post_detail', pk=pk)


@login_required
def post_new(request):
    """新建文章"""
    if request.method == "POST":
        form = PostForm(request.POST)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            # 开始处理标签
            ptags = request.POST['tags'].strip()
            all_tags = []
            if ptags:
                tags = ptags.split(',')
                for tag in tags:
                    try:
                        t = Tag.objects.get(name=tag)
                    except Tag.DoesNotExist:
                        t = Tag(name=tag)
                        t.save()
                    all_tags.append(t)
            post.save()
            for tg in all_tags:
                post.tags.add(tg)
            return redirect('blog.views.post_detail', pk=post.pk)
    else:
        form = PostForm()
    return render(request, 'blog/post_edit.html', {'form': form, 'is_new': True})


@login_required
def post_edit(request, pk):
    """更新文章"""
    post = get_object_or_404(Post, pk=pk)
    if request.method == "POST":
        form = PostForm(request.POST, instance=post)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            # 开始处理标签
            ptags = request.POST['tags'].strip()
            all_tags = []
            if ptags:
                tags = ptags.split(',')
                for tag in tags:
                    try:
                        t = Tag.objects.get(name=tag)
                    except Tag.DoesNotExist:
                        t = Tag(name=tag)
                        t.save()
                    all_tags.append(t)
            post.save()
            post.tags.clear()
            # 文章的新标签更新
            for tg in all_tags:
                post.tags.add(tg)
            # 移除随风漂流的标签
            Tag.objects.annotate(num_post=Count('post')).filter(num_post=0).delete()
            return redirect('blog.views.post_detail', pk=post.pk)
    else:
        form = PostForm(instance=post)
    tags = ','.join([t.name for t in post.tags.all()])
    return render(request, 'blog/post_edit.html', {'form': form, 'tags': tags})


@login_required
def post_draft_list(request):
    posts = Post.objects.filter(published_date__isnull=True).order_by('-created_date')
    return render(request, 'blog/post_draft_list.html', {'posts': posts})


@login_required
def post_publish(request, pk):
    post = get_object_or_404(Post, pk=pk)
    post.publish()
    return redirect('blog.views.post_detail', pk=pk)


@login_required
def post_remove(request, pk):
    post = get_object_or_404(Post, pk=pk)
    post.delete()
    return redirect('blog.views.post_list')

# @login_required
# def uptoken(request):
#     qiniu.conf.ACCESS_KEY = "your access_key"
#     qiniu.conf.SECRET_KEY = "your secret_key"
#     policy = qiniu.rs.PutPolicy('yidaoblog')
#     token = policy.token()
#     return dict(token=token)
#
#
# @login_required
# def imgmanage(request):
#     pass
