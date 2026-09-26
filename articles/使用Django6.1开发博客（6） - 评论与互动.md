---
title: 使用Django6.1开发博客（6） - 评论与互动
slug: django61-blog-06-comments-votes
date: 2026-09-25 23:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

博客能被人读，也需要能被人回应。我先加上匿名评论、顶和踩、热门文章。互动功能第一次把不可信输入带进数据库，验证和转义因此比表单本身更重要。

![](https://static.xiongneng.me/interaction-sequence-20260926000000.png)

评论请求先经过表单验证，再绑定到已发布文章；投票请求先找到文章和浏览器会话，再检查是否已经投过。两者都只在验证通过后写库。

## 评论先建模型再建表单

`Comment` 和 `Post` 是多对一关系。一条评论必须依附于一篇文章，文章删除时评论没有单独存在的意义。

```python
from django.db import models

class Comment(models.Model):
    post = models.ForeignKey(
        Post,
        verbose_name="文章",
        on_delete=models.CASCADE,
        related_name="comments",
    )
    nickname = models.CharField("昵称", max_length=30)
    email = models.EmailField("邮箱")
    body = models.TextField("内容", max_length=2000)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "评论"
        verbose_name_plural = verbose_name
        ordering = ["created_at"]

    def __str__(self):
        return f"{self.nickname} 评论《{self.post.title}》"
```

邮箱暂不要求验证后展示。它可以留给未来回复通知使用，先由 `EmailField` 做格式校验。昵称和内容设上限，能挡掉最明显的滥用。

表单交给 Django 的 `ModelForm`。

```python
from django import forms
from .models import Comment

class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ["nickname", "email", "body"]
        widgets = {
            "nickname": forms.TextInput(attrs={"placeholder": "昵称", "required": True}),
            "email": forms.EmailInput(attrs={"placeholder": "邮箱", "required": True}),
            "body": forms.Textarea(attrs={"placeholder": "写下你的看法", "rows": 4, "required": True}),
        }
```

`fields` 显式列出三个字段。文章主键由 URL 决定，创建时间由数据库生成，这两个都不应该让用户提交。

视图里先找已发布文章，再验证表单。

```python
from django.contrib import messages
from django.shortcuts import get_object_or_404, redirect
from .forms import CommentForm
from .models import Post

def add_comment(request, pk):
    post = get_object_or_404(Post.published, pk=pk)
    form = CommentForm(request.POST)
    if form.is_valid():
        comment = form.save(commit=False)
        comment.post = post
        comment.save()
        messages.success(request, "评论已提交。")
    else:
        messages.error(request, "请检查昵称、邮箱和评论内容。")
    return redirect(post)
```

`save(commit=False)` 先生成对象但不落库，等视图把文章关联上再保存。这样用户只能影响表单列出的字段，不能通过伪造数据把评论挂到别的对象上。

失败时也不需要重新渲染整个详情页。重定向回文章，让 Django messages 显示错误。浏览器刷新后表单还在，用户可以改完再提交。

## 模板默认转义就是防线

详情页展示评论。

```html
{% for comment in post.comments.all %}
  <article class="comment">
    <p class="meta">{{ comment.nickname }} · {{ comment.created_at|date:"Y-m-d H:i" }}</p>
    <p>{{ comment.body|linebreaks }}</p>
  </article>
{% endfor %}
```

`{{ comment.body }}` 默认转义。有人提交 `<script>alert(1)</script>`，页面显示这段文字，浏览器不会执行它。测试里同时断言转义后的文本出现，原始脚本不出现。

```python
self.assertContains(response, "&lt;script&gt;")
self.assertNotContains(response, "<script>alert(1)</script>")
```

这里没有用 Markdown 渲染评论。读者输入不是受控内容，让匿名用户写 HTML 或嵌套 Markdown，会把安全问题扩大。评论先保留纯文本和换行。

## 顶和踩要用数据库约束

文章模型加两个计数列。

```python
class Post(models.Model):
    likes = models.PositiveIntegerField("顶", default=0)
    dislikes = models.PositiveIntegerField("踩", default=0)
```

投票单独建表。只给文章加计数列，刷新页面就多一票，无法限制重复。

```python
class Vote(models.Model):
    post = models.ForeignKey(
        Post,
        verbose_name="文章",
        on_delete=models.CASCADE,
        related_name="votes",
    )
    session_key = models.CharField("浏览器标识", max_length=64, db_index=True)
    value = models.SmallIntegerField("票值", choices=[(1, "顶"), (-1, "踩")])
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=["post", "session_key"], name="unique_post_vote")
        ]
```

`UniqueConstraint` 比应用层判断可靠。两个请求几乎同时到达时，数据库只允许一条记录插入成功。Session Key 不是绝对身份，清 Cookie 后可以再投，这个阶段先接受这个限制。

投票必须是 POST。

```python
from django.db.models import F
from django.views.decorators.http import require_POST
from .models import Post, Vote

@require_POST
def vote(request, pk, value):
    post = get_object_or_404(Post.published, pk=pk)
    vote_value = 1 if value == 1 else -1
    if not request.session.session_key:
        request.session.create()

    _, created = Vote.objects.get_or_create(
        post=post,
        session_key=request.session.session_key,
        defaults={"value": vote_value},
    )
    if not created:
        messages.info(request, "你已经对这篇文章投过票了。")
        return redirect(post)

    if vote_value == 1:
        Post.objects.filter(pk=pk).update(likes=F("likes") + 1)
    else:
        Post.objects.filter(pk=pk).update(dislikes=F("dislikes") + 1)
    messages.success(request, "感谢你的反馈。")
    return redirect(post)
```

`require_POST` 阻止 GET 修改数据。`get_or_create` 和数据库唯一约束一起处理并发。计数更新用 `F` 表达式，和上一篇浏览量的处理一致。

URL 里的 `value` 用整数转换器，模板把踩传成 `0`，视图再映射为 `-1`。Django 的 `<int>` 转换器不接受负号，这样路由仍然保持严格。

## 热门文章先只看浏览量

侧边栏的热门列表已经存在，现在把口径说清楚。第一阶段先用浏览量排序。

```python
popular_posts = Post.published.order_by("-views")[:5]
```

浏览量容易被详情页访问抬高，不代表质量。但它的定义清楚，数据实时，实现便宜。等评论、顶踩积累起来，可以改成加权公式，或者改成后台可配置。现在写一个复杂评分，反而很难解释一篇文章为什么热门。

最新评论也进入侧边栏。

```python
recent_comments = Comment.objects.select_related("post")[:5]
```

`select_related` 把评论和文章一次取回。侧边栏只需要文章标题和链接，不需要评论正文。

详情页下方显示评论数量、列表、表单、顶和踩。

```html
<h2>评论（{{ post.comments.count }}）</h2>
<div class="votes">
  <form method="post" action="{% url 'blog:vote' post.pk 1 %}">
    {% csrf_token %}
    <button type="submit">顶（{{ post.likes }}）</button>
  </form>
  <form method="post" action="{% url 'blog:vote' post.pk 0 %}">
    {% csrf_token %}
    <button type="submit">踩（{{ post.dislikes }}）</button>
  </form>
</div>
```

`comments.count` 会执行一次计数查询。当前详情页数据量小，可读性优先。以后如果计数成为瓶颈，可以在文章上维护评论数缓存列。

真实浏览器打开详情页，提交一条评论，再点一次顶，页面会回到原位并显示提示。

![](https://static.xiongneng.me/blog-interaction-detail-20260925230000.png)

## 测试互动行为和安全边界

评论测试覆盖成功、失败和转义。

```python
def test_comment_can_be_created_and_is_escaped(self):
    response = self.client.post(reverse("blog:comment", args=[self.post.pk]), {
        "nickname": "小明",
        "email": "ming@example.com",
        "body": "<script>alert(1)</script>这条评论很有用。",
    }, follow=True)

    self.assertContains(response, "评论已提交。")
    self.assertContains(response, "&lt;script&gt;")
    self.assertNotContains(response, "<script>alert(1)</script>")
    self.assertEqual(Comment.objects.count(), 1)

def test_invalid_comment_is_not_saved(self):
    response = self.client.post(reverse("blog:comment", args=[self.post.pk]), {
        "nickname": "",
        "email": "bad-email",
        "body": "",
    }, follow=True)

    self.assertContains(response, "请检查昵称、邮箱和评论内容。")
    self.assertEqual(Comment.objects.count(), 0)
```

投票测试用同一个测试客户端发两次 POST。

```python
def test_vote_once_per_session(self):
    url = reverse("blog:vote", args=[self.post.pk, 1])
    self.client.post(url)
    self.client.post(url)

    self.post.refresh_from_db()
    self.assertEqual(self.post.likes, 1)
    self.assertEqual(Vote.objects.count(), 1)
```

热门排序测试创建两篇文章，给其中一篇更高的 `views`，再检查列表侧边栏里的顺序。

```python
def test_popular_posts_are_ordered_by_views(self):
    second = Post.objects.create(
        title="更热门的文章",
        slug="more-popular",
        category=self.category,
        author=self.user,
        status=Post.Status.PUBLISHED,
        published_at="2026-09-25T09:00:00+08:00",
        views=5,
    )
    self.post.views = 1
    self.post.save()

    response = self.client.get(reverse("blog:list"))
    content = response.content.decode()
    self.assertLess(content.index(second.title), content.index(self.post.title))
```

运行迁移和测试。

```bash
uv run manage.py makemigrations blog
uv run manage.py migrate
uv run manage.py test
```

迁移会创建评论、投票表，并给文章加两个计数列。

```text
Migrations for 'blog':
  blog\migrations\0003_post_dislikes_post_likes_comment_vote.py
    + Add field dislikes to post
    + Add field likes to post
    + Create model Comment
    + Create model Vote
```

完整测试结果如下。

```text
Ran 19 tests in 2.918s

OK
```

博客不再只是单向输出。评论有了验证和转义，投票有了数据库约束，热门文章有了明确口径。这些功能都不复杂，但每一条都留下了测试。
