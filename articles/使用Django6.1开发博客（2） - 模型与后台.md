---
title: 使用Django6.1开发博客（2） - 模型与后台
slug: django61-blog-02-models-admin
date: 2026-09-25 19:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

项目骨架能跑以后，我先把博客的数据模型立起来。页面可以晚一点出现，数据边界不能晚。接下来要定义分类、标签和文章三张业务表，打开 Django Admin，再把模型交给测试守住。

![](https://static.xiongneng.me/blog-model-er-20260925180510.png)

图里有四类对象。`User` 来自 Django 的认证系统，`Category` 收敛文章的纵向归属，`Tag` 补充横向主题，`Post` 是这张图的核心。一篇文章只有一个作者和一个分类，可以挂多个标签；一个标签也会被多篇文章使用。

## 先把业务边界画清楚

很多博客教程喜欢一上来创建 `Post`，然后顺手塞一个 `category` 字符串字段。项目能跑，问题会在第二个月出现。有人填 `Python`，有人填 `python`，有人顺手加个空格，以后做分类目录时就要先清洗数据。

所以这里的分类单独建表。名称和 `slug` 都加唯一约束，数据库负责守住重复值。标签也是单独建表，并且通过 `ManyToManyField` 和文章建立关系。分类和标签看起来很像，职责却要分开。分类回答「这篇文章主要属于哪里」，标签回答「这篇文章还涉及哪些主题」。

文章状态也是模型的一部分。草稿和已发布的差别必须能被代码查询，不能靠正文里有没有「写完了」来判断。所以 `Post` 上有 `status` 字段，取值固定在 `draft` 和 `published`。发布时间由模型在首次发布时补上，前台以后只需要相信 `published_at`。

## 创建 blog 应用

进入 `source` 目录，创建业务应用。

```bash
uv run manage.py startapp blog
```

Django 会生成 `blog` 目录。先在 `config/settings.py` 里注册它。

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'blog',
]
```

Django 6.1 生成的应用配置里已经有 `default_auto_field` 和应用名。我再补一个中文的 `verbose_name`，这样后台看到的应用名不会是生硬的 `Blog`。

```python
from django.apps import AppConfig


class BlogConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'blog'
    verbose_name = '博客'
```

## 定义分类和标签

分类和标签的结构很接近，语义却不同。先建两个独立的模型。

```python
from django.db import models


class Category(models.Model):
    """文章分类。目录型内容适合用一对多，而不是把分类写进正文。"""

    name = models.CharField("名称", max_length=50, unique=True)
    slug = models.SlugField("URL 别名", max_length=60, unique=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "分类"
        verbose_name_plural = verbose_name
        ordering = ["name"]

    def __str__(self):
        return self.name


class Tag(models.Model):
    """文章标签。一篇文章可以同时覆盖多个主题。"""

    name = models.CharField("名称", max_length=30, unique=True)
    slug = models.SlugField("URL 别名", max_length=40, unique=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "标签"
        verbose_name_plural = verbose_name
        ordering = ["name"]

    def __str__(self):
        return self.name
```

`name` 给人看，`slug` 给 URL 用。两者都唯一，是为了以后后台和前台都能按名称或地址精确找到对象。`ordering` 写在 `Meta` 里，列表查询默认按名称排，不用每个地方重复写。

`verbose_name` 和 `verbose_name_plural` 也要设置。中文里大多数名词没有复数变化，如果不设置后者，Django Admin 可能会显示成「分类s」。这种小地方影响的是每天打开后台的人。

## Post 模型是本篇核心

文章模型要承载标题、正文、状态、归属和时间。代码先列出来。

```python
from django.conf import settings
from django.db import models
from django.utils import timezone


class PublishedManager(models.Manager):
    """前台以后只从这个管理器读取文章，草稿不会意外漏出去。"""

    def get_queryset(self):
        return super().get_queryset().filter(status=Post.Status.PUBLISHED)


class Post(models.Model):
    class Status(models.TextChoices):
        DRAFT = "draft", "草稿"
        PUBLISHED = "published", "已发布"

    title = models.CharField("标题", max_length=120)
    slug = models.SlugField("URL 别名", max_length=140, unique=True)
    summary = models.CharField("摘要", max_length=240, blank=True)
    body = models.TextField("正文")
    category = models.ForeignKey(
        Category,
        verbose_name="分类",
        on_delete=models.PROTECT,
        related_name="posts",
    )
    tags = models.ManyToManyField(
        Tag,
        verbose_name="标签",
        blank=True,
        related_name="posts",
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        verbose_name="作者",
        on_delete=models.CASCADE,
        related_name="posts",
    )
    status = models.CharField(
        "状态",
        max_length=12,
        choices=Status.choices,
        default=Status.DRAFT,
        db_index=True,
    )
    published_at = models.DateTimeField("发布时间", null=True, blank=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)
    updated_at = models.DateTimeField("更新时间", auto_now=True)

    objects = models.Manager()
    published = PublishedManager()

    class Meta:
        verbose_name = "文章"
        verbose_name_plural = verbose_name
        ordering = ["-published_at", "-created_at"]
        indexes = [
            models.Index(fields=["-published_at", "-created_at"]),
        ]

    def __str__(self):
        return self.title

    def save(self, *args, **kwargs):
        # 首次发布时补发布时间；之后改成草稿也不抹掉历史发布时间。
        if self.status == self.Status.PUBLISHED and self.published_at is None:
            self.published_at = timezone.now()
        super().save(*args, **kwargs)
```

这里有五个决定值得单独说。

第一，作者外键使用 `settings.AUTH_USER_MODEL`。直接写 `auth.User` 在小程序里也能跑，但会降低替换用户模型的可能性。Django 官方文档一直建议项目引用这个设置，而不是硬编码某个用户表。

第二，分类外键使用 `on_delete=models.PROTECT`。分类被文章引用时不允许直接删除。后台误删一个分类，结果不该是一批文章跟着消失，而应该是一个明确的保护错误。

第三，状态用 `TextChoices`。数据库里保存 `draft` 和 `published`，表单和后台展示「草稿」「已发布」。代码判断用常量，界面展示用中文，两边各司其职。

第四，`published` 是一个自定义管理器。以后前台调用 `Post.published.all()`，草稿天然被排除。这个约定比在每个视图里手写 `filter(status="published")` 可靠。

第五，列表页最常用的时间排序写进索引。`ordering` 负责默认顺序，`models.Index` 给数据库一个更省力的路径。博客文章量增加以后，这个索引会比事后补索引便宜得多。

## 生成迁移

模型写完后生成迁移文件。

```bash
uv run manage.py makemigrations blog
```

本阶段输出如下。

```text
Migrations for 'blog':
  blog\migrations\0001_initial.py
    + Create model Category
    + Create model Tag
    + Create model Post
```

打开 `0001_initial.py`，能看到 `Category`、`Tag`、`Post` 的创建语句，还能看到文章和标签的多对多关系。Django 会为这个关系生成一张中间表。我们的代码里只写 `post.tags.add(tag)`，数据库层的关联维护交给迁移和 ORM。

把迁移应用到 SQLite。

```bash
uv run manage.py migrate
```

输出里会有一行。

```text
Applying blog.0001_initial... OK
```

之后执行一次迁移一致性检查。这条命令会进入每个阶段的提交前清单。

```bash
uv run manage.py makemigrations --check --dry-run
```

```text
No changes detected
```

它说明模型和迁移文件一致。以后改了模型却忘记生成迁移，这条命令会比肉眼检查可靠得多。

## 把模型挂到 Django Admin

Admin 很适合模型阶段的验证。它不需要写页面，却能马上暴露字段配置、外键展示、搜索和列表查询的问题。

先创建超级用户。

```bash
uv run manage.py createsuperuser
```

接着在 `blog/admin.py` 注册模型。

```python
from django.contrib import admin

from .models import Category, Post, Tag


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ["title", "category", "author", "status", "published_at"]
    list_filter = ["status", "category", "tags", "author"]
    search_fields = ["title", "summary", "body"]
    prepopulated_fields = {"slug": ["title"]}
    date_hierarchy = "published_at"
    list_select_related = ["category", "author"]
    actions = ["publish_posts"]

    @admin.action(description="发布所选文章")
    def publish_posts(self, request, queryset):
        for post in queryset:
            post.status = Post.Status.PUBLISHED
            post.save(update_fields=["status", "published_at", "updated_at"])


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ["name", "slug", "created_at"]
    search_fields = ["name"]
    prepopulated_fields = {"slug": ["name"]}


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ["name", "slug", "created_at"]
    search_fields = ["name"]
    prepopulated_fields = {"slug": ["name"]}
```

`list_display` 决定列表页能看到什么。文章列表需要标题、分类、作者、状态和发布时间，一眼就能判断内容是否可发布。`list_filter` 加了状态、分类、标签和作者，内容多起来以后，筛选比翻页快。

`search_fields` 覆盖标题、摘要和正文。这里先不用额外搜索引擎，Django Admin 会生成包含 `icontains` 的查询。对几百篇以内的文章足够用，后面做前台全文搜索时再评估是否引入专门组件。

`prepopulated_fields` 是一个省时间的细节。新增文章时输入标题，`slug` 输入框会根据标题预填。它只做辅助，不会阻止手工修改。URL 的稳定性仍然由编辑负责。

`list_select_related` 处理外键查询。文章列表同时展示分类和作者，如果不做关联查询，渲染 20 行就可能产生几十条 SQL。这里提前声明，Django 会在一次查询里把相关行取回来。

自定义动作里的 `save(update_fields=...)` 也值得注意。它只更新状态、发布时间和更新时间，不会把整行数据重新写一遍。并发编辑文章时，覆盖无关字段的机会更少。

启动开发服务器，打开 `http://127.0.0.1:8000/admin/`。

```bash
uv run manage.py runserver 127.0.0.1:8000
```

登录后能看到「博客」应用下面出现三个入口。

![](https://static.xiongneng.me/django-admin-index-20260925181245.png)

进入文章列表，搜索框、筛选器、日期层级和批量操作都在同一页。

![](https://static.xiongneng.me/django-admin-post-list-20260925181245.png)

这一步的目的很实际。模型字段设计有没有漏、中文标签顺不顺、后台操作别不别扭，Admin 页面会马上给出反馈。

## 用测试守住模型约定

Admin 页面确认过了，还不能只靠手点。手点一次是检查，测试才是约束。`blog/tests/test_models.py` 写三条核心测试。

```python
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.utils import timezone

from ..models import Category, Post, Tag


class PostModelTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(
            username="editor",
            password="test-pass-123",
        )
        self.category = Category.objects.create(name="Python", slug="python")
        self.tag = Tag.objects.create(name="Django", slug="django")

    def test_model_str_and_relations(self):
        post = Post.objects.create(
            title="Django 模型入门",
            slug="django-models",
            body="模型是博客数据的骨架。",
            category=self.category,
            author=self.user,
        )
        post.tags.add(self.tag)

        self.assertEqual(str(post), "Django 模型入门")
        self.assertEqual(self.category.posts.count(), 1)
        self.assertEqual(self.tag.posts.count(), 1)

    def test_draft_is_not_in_published_manager(self):
        Post.objects.create(
            title="草稿文章",
            slug="draft-post",
            body="还没准备好。",
            category=self.category,
            author=self.user,
        )
        published = Post.objects.create(
            title="已发布文章",
            slug="published-post",
            body="可以给读者看了。",
            category=self.category,
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at=timezone.now(),
        )

        self.assertEqual(Post.objects.count(), 2)
        self.assertEqual(Post.published.count(), 1)
        self.assertEqual(Post.published.first(), published)

    def test_first_publish_sets_published_at(self):
        post = Post.objects.create(
            title="自动记录发布时间",
            slug="auto-publish-time",
            body="发布时间应该由系统维护。",
            category=self.category,
            author=self.user,
        )
        self.assertIsNone(post.published_at)

        post.status = Post.Status.PUBLISHED
        post.save()
        post.refresh_from_db()

        self.assertIsNotNone(post.published_at)
```

第一条确认模型字符串、分类反查和标签反查。第二条确认草稿不会混进 `Post.published`。第三条确认首次发布会自动记录时间。以后有人把状态过滤删掉，或者把发布时间改成手工传参，测试会先响。

Admin 也要测试。`blog/tests/test_admin.py` 里创建超级用户，检查后台注册页、文章搜索和批量发布动作。

```python
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from ..models import Category, Post, Tag


class PostAdminTests(TestCase):
    def setUp(self):
        self.admin = get_user_model().objects.create_superuser(
            username="admin",
            password="test-pass-123",
            email="admin@example.com",
        )
        self.category = Category.objects.create(name="Python", slug="python")
        self.tag = Tag.objects.create(name="Django", slug="django")
        self.post = Post.objects.create(
            title="后台模型测试",
            slug="admin-model-test",
            body="用于检查 Django Admin。",
            category=self.category,
            author=self.admin,
        )
        self.post.tags.add(self.tag)
        self.client.force_login(self.admin)

    def test_blog_models_are_registered(self):
        response = self.client.get(reverse("admin:index"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "文章")
        self.assertContains(response, "分类")
        self.assertContains(response, "标签")

    def test_post_changelist_and_search(self):
        response = self.client.get(reverse("admin:blog_post_changelist"), {"q": "后台"})

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "后台模型测试")

    def test_publish_action_updates_selected_posts(self):
        url = reverse("admin:blog_post_changelist")
        data = {
            "action": "publish_posts",
            "index": 0,
            "_selected_action": [str(self.post.pk)],
        }

        response = self.client.post(url, data, follow=True)
        self.post.refresh_from_db()

        self.assertEqual(response.status_code, 200)
        self.assertEqual(self.post.status, Post.Status.PUBLISHED)
        self.assertIsNotNone(self.post.published_at)
```

`force_login` 直接建立已登录会话，测试不用重复输入密码。第三条测试模拟 Admin 的批量动作请求，检查数据库里的真实结果。后台界面好用是一回事，动作真的写库又是另一回事。

运行完整测试。

```bash
uv run manage.py test -v 2
```

本阶段的输出如下。

```text
Found 9 test(s).
test_blog_models_are_registered (blog.tests.test_admin.PostAdminTests.test_blog_models_are_registered) ... ok
test_post_changelist_and_search (blog.tests.test_admin.PostAdminTests.test_post_changelist_and_search) ... ok
test_publish_action_updates_selected_posts (blog.tests.test_admin.PostAdminTests.test_publish_action_updates_selected_posts) ... ok
test_draft_is_not_in_published_manager (blog.tests.test_models.PostModelTests.test_draft_is_not_in_published_manager) ... ok
test_first_publish_sets_published_at (blog.tests.test_models.PostModelTests.test_first_publish_sets_published_at) ... ok
test_model_str_and_relations (blog.tests.test_models.PostModelTests.test_model_str_and_relations) ... ok
test_django_version_is_61 (tests.test_project.ProjectInitializationTests.test_django_version_is_61) ... ok
test_manage_check_runs_without_warnings (tests.test_project.ProjectInitializationTests.test_manage_check_runs_without_warnings) ... ok
test_python_and_base_settings (tests.test_project.ProjectInitializationTests.test_python_and_base_settings) ... ok

----------------------------------------------------------------------
Ran 9 tests in 2.793s

OK
```

第一篇的 3 条项目测试还在，新加的 6 条测试分别覆盖模型和后台。老测试没有被扔掉，这很重要。项目骨架和数据模型开始叠在一起，回归测试才能保证后面的功能没有踩坏前面的约定。

提交前再跑一遍基础检查。

```bash
uv run manage.py check
uv run manage.py makemigrations --check --dry-run
```

输出如下。

```text
System check identified no issues (0 silenced).
No changes detected
```

博客的数据结构现在可以被稳定管理。分类负责主归属，标签负责横向主题，文章状态由模型和测试一起保护；Admin 也把这些结构变成了可以日常操作的界面。
