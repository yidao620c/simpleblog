---
title: 使用Django6.1开发博客（3） - 页面与详情
slug: django61-blog-03-views-templates
date: 2026-09-25 20:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

模型稳住以后，博客该见人了。我先接通文章列表和详情页，顺手处理两个很容易拖到上线后的问题。草稿不能因为一个判断写漏就跑到前台；浏览量也不能在并发访问里被旧值覆盖。

![](https://static.xiongneng.me/blog-request-sequence-20260926000000.png)

一个读者请求先经过根路由，再进入 `blog` 应用的路由，最后到达视图。视图只取已发布文章，交给模板渲染。详情页还会多一步浏览量更新。

## 路由要从项目边界开始分清

`config/urls.py` 继续只做总入口。

```python
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("blog.urls")),
]
```

博客自己的路由放进 `blog/urls.py`。

```python
from django.urls import path
from . import views

app_name = "blog"

urlpatterns = [
    path("", views.post_list, name="list"),
    path("post/<int:pk>/", views.post_detail, name="detail"),
]
```

`app_name` 现在看不出作用，等后台模板、邮件模板或前端页面都要反转 URL 时，它能避免名字撞车。`blog:list` 和 `blog:detail` 比裸的 `list` 更容易检索。

详情页先用主键。有人喜欢一开始就做 `slug` 路由，可 `slug` 会因为标题调整而变动，主键始终稳定。等站内链接、缓存键和搜索跳转都清楚以后，再决定是否把 URL 全部迁到日期加别名。

路由名我也保留了少量冗余。`path("", views.post_list, name="list")` 里，路径是空字符串，名字却是 `list`。有人觉得空路径可以直接叫 `index`。我倾向 `list`，因为它描述的是资源集合的行为，不是技术上的默认首页。以后加归档、标签、分类页时，`blog:archive`、`blog:tag`、`blog:category` 会自然排在一起。

`<int:pk>` 也有一个隐含约定。它只匹配整数，不会把 `/post/abc/` 送进视图，也不会让数据库先收到一个明显非法的值。Django 在路由层就把这类请求挡下来。URL 转换器看起来只是语法糖，实际减少了很多视图开头的类型判断。

## 视图只做请求层的事

列表视图非常短。

```python
from django.shortcuts import render
from .models import Post

def post_list(request):
    posts = Post.published.select_related("category").prefetch_related("tags")
    return render(request, "blog/post_list.html", {"posts": posts})
```

这里没有手写 `filter(status="published")`，因为上一篇已经在模型里定义了 `Post.published`。前台所有地方都走这个出口，草稿就只有一条规则可守。

`select_related("category")` 处理外键。列表页要显示分类名，如果不合并查询，每渲染一张卡片都会多查一次分类。`prefetch_related("tags")` 处理多对多。当前页面暂时还没有展示标签，先把查询取齐，下一篇展示标签时就不用改数据访问层。

详情页多了浏览量。

```python
from django.db.models import F
from django.shortcuts import get_object_or_404, render

def post_detail(request, pk):
    post = get_object_or_404(
        Post.published.select_related("category").prefetch_related("tags"),
        pk=pk,
    )
    Post.objects.filter(pk=pk).update(views=F("views") + 1)
    post.refresh_from_db(fields=["views"])
    return render(request, "blog/post_detail.html", {"post": post})
```

`F("views") + 1` 会把加法交给数据库。两个人同时打开同一篇文章时，SQL 里都是「在当前值上加一」，不会出现两个人都拿着旧值 10 写回 11 的情况。随后 `refresh_from_db` 只取浏览量这一列，模板拿到的是最新值。

`get_object_or_404` 的第一个参数仍然是 `Post.published`。所以别人手动输入一篇草稿的详情地址时，看到的是 404。这个 404 就是产品语义，草稿对前台不存在。

我故意没有在视图里写分页、侧边栏、推荐文章这些东西。列表页刚出现时，最需要确认的是「取哪些数据」和「不取哪些数据」。分页会改变 URL 的含义，侧边栏会引入跨模型查询，推荐文章又牵涉排序规则。把它们塞进第一个视图，短期看完成得快，长期看每个功能都会在同一个函数里抢位置。

函数视图已经够用。它没有隐藏参数，也没有继承链，请求进来后先做什么、后做什么一眼能看到。Django 的通用视图当然有价值，比如 `ListView` 自带分页，`DetailView` 自带对象查找。可这些便利只在规则匹配时才省事。现在博客的规则还在形成中，先让普通函数把路径铺平，后面出现明显重复时再收拢。

模板异常也提醒我们目录配置的重要性。第一次跑测试时，视图和 URL 都正常，浏览器却提示 `TemplateDoesNotExist`。原因是 `settings.py` 里的 `DIRS` 仍然是空列表，Django 只会在应用目录里找模板。把 `BASE_DIR / "templates"` 加进去以后，公共模板才被找到。这个配置只写一次，但每个新项目都值得确认。

## 模板只负责展示

Django 6.1 默认会查找应用里的 `templates` 目录。这个项目的页面数量会增加，我先把公共页面放在 `source/templates`，把文章页放在 `source/templates/blog`。`settings.py` 里补上目录。

```python
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]
```

`base.html` 保留每个页面都会用的骨架。

```html
{% load static %}
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{% block title %}Django 6.1 博客{% endblock %}</title>
  <link rel="stylesheet" href="{% static 'css/blog.css' %}">
</head>
<body>
<header class="site-header">
  <nav>
    <a class="brand" href="{% url 'blog:list' %}">Django 6.1 博客</a>
    <p class="tagline">把一个博客慢慢做完</p>
  </nav>
</header>
<main class="layout">
  {% block content %}{% endblock %}
</main>
</body>
</html>
```

列表页循环输出文章卡片。

```html
{% extends "base.html" %}
{% block title %}文章列表{% endblock %}
{% block content %}
<section class="content">
  <h1>文章列表</h1>
  <div class="post-list">
    {% for post in posts %}
      <article class="post-card">
        <h2><a href="{{ post.get_absolute_url }}">{{ post.title }}</a></h2>
        <p class="meta">
          {{ post.published_at|date:"Y-m-d H:i" }} · {{ post.category.name }} · {{ post.views }} 阅读
        </p>
        <p>{{ post.summary|default:post.body|truncatechars:120 }}</p>
      </article>
    {% empty %}
      <p class="empty">还没有已发布文章。</p>
    {% endfor %}
  </div>
</section>
{% endblock %}
```

`summary` 可以在后台手工写。它为空时退回正文，并用 `truncatechars` 截断。这里不追求智能摘要，先让列表页不会把长正文全部铺出来。

模型里补一个反载数据库。

```python
from django.urls import reverse

class Post(models.Model):
    def get_absolute_url(self):
        return reverse("blog:detail", args=[self.pk])
```

模板调用 `post.get_absolute_url`，不用知道 URL 长什么样。以后调整路由，只要 `get_absolute_url` 还返回正确地址，列表页就不用跟着改。

`base.html` 现在只承担最稳定的三件事。第一是 HTML 语言和响应式视口，第二是页面标题的替换点，第三是全局样式入口。导航、页脚和侧边栏以后会出现，但它们也必须回答一个问题，这个区域是不是每一页都需要。答案不确定时，先不要放进基类。

列表模板用 `{% extends %}` 接住骨架，只填充标题和内容。这种继承比 `include` 更适合页面结构。`include` 适合复用一张卡片、一个表单行、一个按钮组；`extends` 适合固定页面外框。两者混用没有问题，但如果一个模板既继承又频繁反向包含，多半说明布局切分需要重新想。

文章详情页保留一条面包屑。它不是装饰，读者从搜索或后台预览进入详情时，需要一个明确的返回入口。链接文本直接写「文章列表」，不写「返回」。用户要返回的是一个页面，不是浏览器历史里的某一步。

样式先保持克制。纸张色背景、白色卡片、细边框、一个青绿色强调色，足够把层级做清楚。移动端只需要保证 `max-width` 和正常的字体行高，不需要一开始就堆组件。

这套样式里有几个值会反复出现，所以抽成 CSS 变量。`--paper` 控制背景，`--ink` 控制正文，`--line` 控制边界，`--accent` 控制强调。颜色不需要多，但同一个语义必须同一个值。否则今天列表卡片是 `#ffffff`，明天详情页是 `#fff`，后天某个容器又写白色，后面想统一调整就要全文搜索。

布局宽度限制在 `760px`。中文长段落超过这个宽度后，眼睛换行会变累。外层 `.layout` 允许到 `1080px`，是为了给以后的侧边栏留位置；正文区继续收窄，让阅读优先。

```css
body {
  margin: 0;
  background: #fbfaf8;
  color: #172033;
  font: 16px/1.75 system-ui, -apple-system, "Segoe UI", "Microsoft YaHei", sans-serif;
}
.post-card {
  background: white;
  border: 1px solid #e6e2db;
  border-radius: 1rem;
  padding: 1.25rem 1.5rem;
  margin-bottom: 1rem;
  box-shadow: 0 8px 24px rgba(23,32,51,.04);
}
.content {
  max-width: 760px;
  margin: auto;
}
```

启动服务后打开首页，已发布文章会按发布时间排列。

![](https://static.xiongneng.me/blog-list-page-20260925190000.png)

点进标题，详情页显示完整正文、分类和浏览量。

![](https://static.xiongneng.me/blog-detail-page-20260925190000.png)

## 测试要盯住访问边界

页面功能最容易退化的地方是状态过滤。`blog/tests/test_views.py` 里先写三条测试。

```python
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from ..models import Category, Post

class PostViewTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(username="editor")
        self.category = Category.objects.create(name="Python", slug="python")
        self.post = Post.objects.create(
            title="博客的第一页",
            slug="first-page",
            summary="列表和详情已经接通。",
            body="这是详情页正文。",
            category=self.category,
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at="2026-09-25T09:00:00+08:00",
        )

    def test_list_shows_only_published_posts(self):
        Post.objects.create(
            title="不能出现的草稿",
            slug="hidden-draft",
            category=self.category,
            author=self.user,
        )
        response = self.client.get(reverse("blog:list"))

        self.assertContains(response, "博客的第一页")
        self.assertNotContains(response, "不能出现的草稿")

    def test_detail_renders_and_counts_view(self):
        response = self.client.get(self.post.get_absolute_url())
        self.post.refresh_from_db()

        self.assertContains(response, "这是详情页正文。")
        self.assertEqual(self.post.views, 1)

    def test_draft_detail_returns_404(self):
        self.post.status = Post.Status.DRAFT
        self.post.save()
        response = self.client.get(self.post.get_absolute_url())

        self.assertEqual(response.status_code, 404)
```

这三条测试分别守住列表可见性、详情渲染加计数、草稿不可访问。它们都不依赖固定主键，也不检查某段 CSS 类名。页面重构时，这些测试不需要跟着改。

测试客户端不启动浏览器，也不执行 JavaScript，所以它适合验证响应状态、模板上下文和页面里的关键文本。布局是否溢出、按钮好不好点、暗色模式是否刺眼，这些仍然要打开真实页面看。两种检查各自服务不同问题，不能用一方完全替代另一方。

浏览量测试里还有一个细节。客户端请求详情页以后，代码调用 `refresh_from_db`。如果不刷新，`self.post.views` 还是内存里的旧值，测试可能碰巧通过，也可能在不同数据库顺序下失败。测试不能靠运气。

写这些测试时，我没有先打开浏览器截一个结果，再根据页面内容写断言。先写测试会强迫我把行为说清楚。比如草稿在列表里不出现是一件事，草稿详情返回 404 是另一件事。两个行为都成立，才算草稿真的不可见。如果只断言列表页没有标题，详情页仍然可能漏。

断言里的文本也选得比较挑剔。「博客的第一页」是标题，「这是详情页正文。」是正文。它们能证明模板拿到了正确对象。反过来，如果我断言某个 HTML 标签或某个 class，模板稍微调整结构，测试就会变红。这种失败并不代表业务坏了，只会让人慢慢忽略测试。

提交前运行检查。

```bash
uv run manage.py check
uv run manage.py makemigrations --check --dry-run
uv run manage.py test
```

本阶段共 12 条测试，全部通过。

```text
Ran 12 tests in 2.967s

OK
```

这些数字本身不重要，重要的是变化。第一篇只有 3 条项目级测试，第二篇加入模型和后台后变成 9 条，这一篇补上页面后变成 12 条。每加一个功能，测试数量不需要追求固定比例，但已经建立的行为必须有地方守住。

评论、分页和标签页都还没加。页面数量很少，可请求路径已经完整。
