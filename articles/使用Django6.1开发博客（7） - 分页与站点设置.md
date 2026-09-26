---
title: 使用Django6.1开发博客（7） - 分页与站点设置
slug: django61-blog-07-pagination-settings
date: 2026-09-26 00:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

列表、分类、标签和归档都会随着文章增多变长。我给它们加同一套分页，并把每页数量放进 Django Admin。编辑改一个数字，所有文章列表一起生效。

![](https://static.xiongneng.me/pagination-dataflow-20260926000000.png)

请求进入视图后，文章集合先按业务规则过滤，再交给 `Paginator`。页大小来自 `SiteSetting`，页码来自 URL 的 `page` 参数。模板只接收 `page_obj`，不用关心当前视图是列表、分类还是归档。

## 全局设置只允许一行

站点设置通常只需要一条记录。用一个模型表示它，再把主键固定住。

```python
from django.db import models

class SiteSetting(models.Model):
    site_name = models.CharField("站点名称", max_length=80, default="Django 6.1 博客")
    page_size = models.PositiveSmallIntegerField("每页文章数", default=10)
    updated_at = models.DateTimeField("更新时间", auto_now=True)

    class Meta:
        verbose_name = "站点设置"
        verbose_name_plural = verbose_name

    def __str__(self):
        return self.site_name

    def save(self, *args, **kwargs):
        # 强制主键为 1，避免后台或脚本误建多行全局设置。
        self.pk = 1
        super().save(*args, **kwargs)

    @classmethod
    def load(cls):
        return cls.objects.get_or_create(pk=1)[0]
```

`save` 里的 `self.pk = 1` 让所有保存都落在同一行。`load` 用 `get_or_create` 初始化记录。第一次访问页面时会自动创建默认设置，不需要额外迁移数据。

每页数量用 `PositiveSmallIntegerField`。一个博客列表不太可能每页几万篇，小整数已经足够。如果以后允许管理员填任意数字，再在表单里加范围校验。

Admin 注册也很短。

```python
from django.contrib import admin
from .models import SiteSetting

@admin.register(SiteSetting)
class SiteSettingAdmin(admin.ModelAdmin):
    list_display = ["site_name", "page_size", "updated_at"]

    def has_add_permission(self, request):
        return not SiteSetting.objects.exists()
```

已有设置后，`has_add_permission` 返回 false。后台不再显示新增入口。修改仍然走变更页。

## 分页收在一个函数里

所有文章列表都要分页，所以不要把 `Paginator` 复制四次。

```python
from django.core.paginator import Paginator
from .models import SiteSetting

def paginate_posts(request, posts):
    page_size = SiteSetting.load().page_size
    return Paginator(posts, page_size).get_page(request.GET.get("page"))
```

列表页调用它。

```python
def post_list(request):
    posts = Post.published.select_related("category").prefetch_related("tags")
    return render(request, "blog/post_list.html", {
        **sidebar_context(),
        "page_obj": paginate_posts(request, posts),
    })
```

分类页、标签页和归档页也替换成同样模式。它们先各自过滤业务范围，最后统一进入 `paginate_posts`。

```python
page_obj = paginate_posts(request, posts)
return render(request, "blog/post_list.html", {
    **sidebar_context(),
    "page_obj": page_obj,
    "page_title": f"分类：{category.name}",
})
```

`Paginator.get_page` 是这里的关键。页码是 `1` 或 `2` 时返回对应页；页码不是数字、小于 1 或超过总页数时，它不抛异常，只返回第一页或最后一页。`/list/?page=999` 仍然是一个正常页面，不会变成 500。

这个选择适合博客。读者可能收藏了旧地址，文章删除后总页数变化，跳回最后一页比显示错误更友好。如果是 API，处理方式可能不同，显式返回 404 更容易让调用方发现问题。

## 模板只接收 page_obj

列表模板循环 `page_obj`。

```html
{% for post in page_obj %}
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
```

有第二页时再显示导航。

```html
{% if page_obj.has_other_pages %}
  <nav class="pagination">
    {% if page_obj.has_previous %}
      <a href="?page={{ page_obj.previous_page_number }}">上一页</a>
    {% endif %}
    <span>第 {{ page_obj.number }} / {{ page_obj.paginator.num_pages }} 页</span>
    {% if page_obj.has_next %}
      <a href="?page={{ page_obj.next_page_number }}">下一页</a>
    {% endif %}
  </nav>
{% endif %}
```

只有一页时不渲染任何分页控件。首页没有「上一页」，最后一页没有「下一页」。这比禁用按钮更安静。

样式让分页保持在内容底部。

```css
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-top: 1.5rem;
}
```

以后列表页加入搜索或筛选参数，翻页链接也要带上这些参数。当前还没有查询条件，`?page=` 已经够用。

## 测试后台设置和边界页码

准备三篇文章，把页大小改成 2。

```python
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from ..models import Category, Post, SiteSetting

class PaginationTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(username="editor")
        self.category = Category.objects.create(name="Python", slug="python")
        for number in range(1, 4):
            Post.objects.create(
                title=f"第 {number} 篇文章",
                slug=f"post-{number}",
                category=self.category,
                author=self.user,
                status=Post.Status.PUBLISHED,
                published_at=f"2026-09-0{number}T09:00:00+08:00",
            )

    def test_admin_can_change_page_size(self):
        setting = SiteSetting.load()
        setting.page_size = 2
        setting.save()

        first = self.client.get(reverse("blog:list"))
        second = self.client.get(reverse("blog:list"), {"page": 2})

        self.assertEqual(
            [post.title for post in first.context["page_obj"]],
            ["第 3 篇文章", "第 2 篇文章"],
        )
        self.assertContains(second, "第 2 / 2 页")

    def test_invalid_page_falls_back_to_valid_page(self):
        setting = SiteSetting.load()
        setting.page_size = 2
        setting.save()

        response = self.client.get(reverse("blog:list"), {"page": "999"})
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "第 2 / 2 页")
```

第一条测试检查了 `response.context` 里的对象列表，不只检查标题是否出现在 HTML。侧边栏也会显示文章标题，只看页面文本分不清主列表和最新文章。

第二条测试确认超过范围的页码不会抛异常。`get_page` 把它拉回最后一页。

生成迁移并运行测试。

```bash
uv run manage.py makemigrations blog
uv run manage.py migrate
uv run manage.py test
```

迁移输出如下。

```text
Migrations for 'blog':
  blog\migrations\0004_sitesetting.py
    + Create model SiteSetting
```

最终测试结果如下。

```text
Ran 21 tests in 2.942s

OK
```

把每页数量改成 2 后，首页显示两篇文章，底部出现下一页；第二页显示剩下的一篇，并出现页码。

![](https://static.xiongneng.me/blog-pagination-page2-20260926000000.png)

列表增长的入口已经收住。分类、标签、归档共用同一个页大小，后台设置也只维护一行数据。
