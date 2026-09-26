---
title: 使用Django6.1开发博客（5） - 分类标签与归档
slug: django61-blog-05-taxonomy-archive
date: 2026-09-25 22:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

文章多了以后，列表页会变成一条长队。读者想找的内容通常很具体，可能看某个分类，可能记得写作月份，也可能只记得一个标签。我先把这三条找文章的路补上，同时给每一页加上侧边栏。

![](https://static.xiongneng.me/taxonomy-class-diagram-20260926000000.png)

分类、标签、归档分别回答三个问题。分类说文章主要属于哪里，标签说文章还涉及什么，归档说文章出现在哪个时间。三者不互相替代。

## 先把反查入口放到模型上

分类和标签的 `get_absolute_url` 现在补上。

```python
from django.urls import reverse

class Category(models.Model):
    def get_absolute_url(self):
        return reverse("blog:category", args=[self.slug])

class Tag(models.Model):
    def get_absolute_url(self):
        return reverse("blog:tag", args=[self.slug])
```

这两个方法看起来只是两行反转。它们的价值在于，模板、后台跳转、未来的 RSS 和搜索结果都能调用同一个地址。分类页换路径时，只要模型方法更新，页面里的入口就不会散落。

路由集中在 `blog/urls.py`。

```python
path("category/<slug:slug>/", views.category_posts, name="category"),
path("tag/<slug:slug>/", views.tag_posts, name="tag"),
path("tags/", views.tag_cloud, name="tags"),
path("archive/<int:year>/<int:month>/", views.archive_posts, name="archive"),
```

`slug` 和 `year`、`month` 都用转换器约束。分类名不需要出现在路径里，固定一个短别名更稳定。归档路径用数字年月，不用字符串解析。

## 分类页只取一个分类的已发布文章

分类视图很简单。

```python
from django.shortcuts import get_object_or_404, render
from .models import Category, Post

def category_posts(request, slug):
    category = get_object_or_404(Category, slug=slug)
    posts = (
        Post.published.filter(category=category)
        .select_related("category")
        .prefetch_related("tags")
    )
    return render(request, "blog/post_list.html", {
        "posts": posts,
        "page_title": f"分类：{category.name}",
        **sidebar_context(),
    })
```

这里的 `get_object_or_404` 负责处理不存在的 `slug`。后面的过滤从 `Post.published` 开始，仍然沿用前台唯一出口。就算有人在后台把分类建好了，文章还停在草稿状态，分类页也不会把它带出来。

标签视图逻辑相同。

```python
def tag_posts(request, slug):
    tag = get_object_or_404(Tag, slug=slug)
    posts = (
        Post.published.filter(tags=tag)
        .select_related("category")
        .prefetch_related("tags")
    )
    return render(request, "blog/post_list.html", {
        "posts": posts,
        "page_title": f"标签：{tag.name}",
        **sidebar_context(),
    })
```

两个视图没有急着抽成同一个函数。它们目前只差一个过滤字段和标题前缀，重复两遍还能看清楚。等出现第三种类似筛选，再考虑共同参数和视图函数的组合。过早抽象常常把简单的过滤器写成配置对象。

归档页按年和月过滤。

```python
def archive_posts(request, year, month):
    posts = Post.published.filter(
        published_at__year=year,
        published_at__month=month,
    ).select_related("category").prefetch_related("tags")
    return render(request, "blog/post_list.html", {
        "posts": posts,
        "page_title": f"{year} 年 {month} 月归档",
        **sidebar_context(),
    })
```

项目开启了 `USE_TZ`，Django 会按当前时区解释年月查询。文章在 2026 年 9 月 1 日凌晨发布时，归档应该算 9 月，而不能因为数据库里保存 UTC 就落到 8 月。

## 侧边栏统一提供导航

侧边栏的数据来自一个函数。

```python
from django.db.models import Count

def sidebar_context():
    archives = (
        Post.published
        .filter(published_at__isnull=False)
        .values("published_at__year", "published_at__month")
        .annotate(total=Count("id"))
        .order_by("-published_at__year", "-published_at__month")
    )
    return {
        "latest_posts": Post.published.all()[:5],
        "popular_posts": Post.published.order_by("-views")[:5],
        "sidebar_categories": Category.objects.annotate(total=Count("posts")).filter(total__gt=0),
        "archives": archives,
    }
```

函数名里带 `context`，说明它返回的是数据，不负责渲染。每个页面视图把结果展开进上下文，模板不需要知道聚合从哪来。

分类数量用 `annotate(total=Count("posts"))`，再用 `filter(total__gt=0)` 过滤。空分类不出现在侧边栏，因为一个没有文章的入口只会带来 404。

归档分组先用 `values` 取年月，再聚合数量。生成的 SQL 会按年月分组，`order_by` 保证最近的月份排在前面。以后文章跨很多年，可以在这一层继续做年度折叠。

最新文章和热门文章都限制在 5 条。侧边栏是辅助导航，不能比正文还长。热门排序先沿用浏览量，后面如果要做更复杂的推荐，再单独讨论统计口径。

模板放进 `includes/sidebar.html`。

```html
<aside class="sidebar">
  <div class="panel">
    <h2>分类</h2>
    <ul>
      {% for category in sidebar_categories %}
        <li><a href="{{ category.get_absolute_url }}">{{ category.name }}（{{ category.total }}）</a></li>
      {% endfor %}
    </ul>
  </div>
  <div class="panel">
    <h2>归档</h2>
    <ul>
      {% for item in archives %}
        <li>
          <a href="{% url 'blog:archive' item.published_at__year item.published_at__month %}">
            {{ item.published_at__year }} 年 {{ item.published_at__month }} 月（{{ item.total }}）
          </a>
        </li>
      {% endfor %}
    </ul>
  </div>
</aside>
```

列表页和详情页都包含它。

```html
{% include "includes/sidebar.html" %}
```

页面外层改成两栏网格。

```css
.page-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 280px;
  gap: 2rem;
  align-items: start;
}

@media (max-width: 900px) {
  .page-grid { grid-template-columns: 1fr; }
}
```

`minmax(0, 1fr)` 是关键。正文里有长代码时，普通 `1fr` 可能被内容撑开，整个页面横向滚动。加上 `minmax(0, 1fr)` 后，正文栏遵守网格宽度，代码块自己横向滚动。

打开一个分类页，左侧是筛选结果，右侧是分类、最新、热门和归档。

![](https://static.xiongneng.me/blog-category-sidebar-20260925220000.png)

## 标签云用一个简单比例

标签云不是把所有标签平铺出来。出现频率要有视觉差异，但不能大到把小标签挤没。

```python
from django.db.models import Count

def tag_cloud(request):
    tags = Tag.objects.annotate(total=Count("posts")).filter(total__gt=0)
    max_count = max((tag.total for tag in tags), default=1)
    for tag in tags:
        tag.font_size = 100 + int(60 * tag.total / max_count)
    return render(request, "blog/tag_cloud.html", {"tags": tags, **sidebar_context()})
```

`max_count` 是当前最多文章的标签数量。普通标签的字号是基准 100%，数量最多的标签放大到 160%。中间的标签按比例落在这个区间。

这个算法不复杂，但它有三个优点。第一，字号永远不会小于正文字号，标签仍然可点。第二，一张只有 1 篇和 2 篇文章的博客，也能看出差异。第三，新增热门标签时，其他标签会相对缩小，不会固定在旧权重上。

模板里用行内样式输出字号。

```html
<p class="cloud">
  {% for tag in tags %}
    <a style="font-size: {{ tag.font_size }}%" href="{{ tag.get_absolute_url }}">
      {{ tag.name }}（{{ tag.total }}）
    </a>
  {% endfor %}
</p>
```

有人会担心行内样式。这里只是一个从后端算出的动态值，放进 CSS 类没有意义。公共布局仍然交给样式表，动态比例留在模板里，职责反而更清楚。

## 测试三条入口和标签云

在原有视图测试里加两条。

```python
def test_category_tag_and_archive_pages(self):
    category_response = self.client.get(self.category.get_absolute_url())
    tag_response = self.client.get(self.tag.get_absolute_url())
    archive_response = self.client.get("/archive/2026/9/")

    self.assertContains(category_response, "博客的第一页")
    self.assertContains(tag_response, "博客的第一页")
    self.assertContains(archive_response, "博客的第一页")
    self.assertContains(category_response, "热门文章")

def test_tag_cloud_contains_tag(self):
    response = self.client.get(reverse("blog:tags"))
    self.assertContains(response, "Django")
    self.assertContains(response, "font-size: 160%")
```

第一条测试一次覆盖三个页面。它们共同验证同一篇文章在已发布状态下能被不同入口找到。第二条测试检查标签云聚合和字号映射。

运行完整测试。

```bash
uv run manage.py check
uv run manage.py makemigrations --check --dry-run
uv run manage.py test
```

本阶段共 15 条测试。

```text
Ran 15 tests in 2.880s

OK
```

博客现在不止有一条时间线。分类负责结构，标签负责主题，归档负责时间，侧边栏把这些入口放在每页旁边。读者可以从任何一个维度继续往下翻。
