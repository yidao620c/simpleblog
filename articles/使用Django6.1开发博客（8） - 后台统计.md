---
title: 使用Django6.1开发博客（8） - 后台统计
slug: django61-blog-08-admin-stats
date: 2026-09-26 08:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

文章后台已有管理入口，但管理员每天关心的几个数字还得点进列表慢慢数。我把基础统计放进文章列表页上方，显示文章总数、发布数、草稿数、浏览总量和平均浏览量。

![](https://static.xiongneng.me/admin-stats-component-20260926000000.png)

数据仍然从数据库实时聚合。博客规模不大，这样做最诚实。等访问量上来，再把统计结果放进缓存或定时汇总表。

## 统计放在哪里

我把它放在文章列表页顶部，而不是单独做一个新页面。管理员看完数字，马上就能在下方处理文章。跳页会增加一次上下文切换。

Django Admin 的 `ModelAdmin` 可以覆盖 `changelist_view`。这个视图原本负责渲染文章列表，我们在它调用父类前，把统计结果塞进模板上下文。

```python
from django.db import models
from django.db.models import Count, Sum

class PostAdmin(admin.ModelAdmin):
    def changelist_view(self, request, extra_context=None):
        stats = Post.objects.aggregate(
            total=Count("id"),
            published=Count("id", filter=models.Q(status=Post.Status.PUBLISHED)),
            draft=Count("id", filter=models.Q(status=Post.Status.DRAFT)),
            views=Sum("views"),
        )
        total = stats["total"] or 1
        stats["average_views"] = (stats["views"] or 0) / total
        extra_context = {"blog_stats": stats, **(extra_context or {})}
        return super().changelist_view(request, extra_context)
```

`Count("id", filter=...)` 是条件聚合。一次 `aggregate` 调用拿到总数、发布数、草稿数和浏览总量。状态值来自 `Post.Status`，避免在查询里散落魔法字符串。

平均浏览量没有和 `Sum` 放进同一个 `aggregate`。同一个字段在一个聚合里同时取总和和平均值，容易触发聚合嵌套问题。这里先取总和与总数，再用 Python 做除法。

`total` 为零时用 `or 1` 兜底。没有文章时平均浏览量就是零，也不会抛 `ZeroDivisionError`。

## 覆盖文章列表模板

Django Admin 会按应用和模型找模板。文章模型位于 `blog.post`，所以模板路径是 `templates/admin/blog/post/change_list.html`。

```html
{% extends "admin/change_list.html" %}

{% block result_list %}
  <div class="blog-stats module">
    <h2>博客统计</h2>
    <ul>
      <li>文章总数：{{ blog_stats.total }}</li>
      <li>已发布：{{ blog_stats.published }}</li>
      <li>草稿：{{ blog_stats.draft }}</li>
      <li>浏览总量：{{ blog_stats.views|default:0 }}</li>
      <li>平均浏览量：{{ blog_stats.average_views|floatformat:1 }}</li>
    </ul>
  </div>
  {{ block.super }}
{% endblock %}
```

`{{ block.super }}` 很重要。它保留父模板里原来的结果列表和操作区，统计块只插在前面。没有这一行，文章列表会被统计块覆盖。

再加一点 Admin 样式。

```css
.blog-stats {
  margin-bottom: 1rem;
  padding: 12px;
  background: #f8f8f8;
  border-radius: 4px;
}
```

管理员打开文章列表，统计卡就在筛选器和表格上方。

![](https://static.xiongneng.me/admin-post-stats-20260926080000.png)

## 用测试检查数字

后台页面容易因为 Admin 升级改变结构。测试不看 CSS 类，只看业务文本和上下文。

```python
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from ..models import Category, Post

class PostAdminStatsTests(TestCase):
    def test_changelist_shows_basic_statistics(self):
        admin = get_user_model().objects.create_superuser(
            username="admin",
            password="test-pass-123",
        )
        category = Category.objects.create(name="Python", slug="python")
        Post.objects.create(
            title="已发布统计",
            slug="published-stats",
            category=category,
            author=admin,
            status=Post.Status.PUBLISHED,
            views=8,
        )
        Post.objects.create(
            title="草稿统计",
            slug="draft-stats",
            category=category,
            author=admin,
        )
        self.client.force_login(admin)

        response = self.client.get(reverse("admin:blog_post_changelist"))

        self.assertContains(response, "博客统计")
        self.assertContains(response, "文章总数：2")
        self.assertContains(response, "浏览总量：8")
```

两条文章用同一个作者和分类。发布文章有 8 次浏览，草稿没有浏览量。页面应该显示总数 2、发布数 1、草稿数 1、浏览总量 8、平均 4。

运行测试。

```bash
uv run manage.py test
```

本阶段有 23 条测试。

```text
Ran 23 tests in 3.588s

OK
```

这些统计不求复杂。管理员先能回答「现在有多少内容，多少被人看过」。以后要做趋势、转化、留存，再引入专门的数据表和任务。
