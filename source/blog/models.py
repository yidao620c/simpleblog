from django.conf import settings
from django.db import models
from django.urls import reverse
from django.utils import timezone
from django.core.files.storage import FileSystemStorage

from .storage import AliyunOSSStorage


class SiteSetting(models.Model):
    """全局站点设置。数据库里只允许一行。"""

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

    def get_absolute_url(self):
        return reverse("blog:category", args=[self.slug])


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

    def get_absolute_url(self):
        return reverse("blog:tag", args=[self.slug])


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
    views = models.PositiveIntegerField("浏览量", default=0)
    likes = models.PositiveIntegerField("顶", default=0)
    dislikes = models.PositiveIntegerField("踩", default=0)
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

    def get_absolute_url(self):
        return reverse("blog:detail", args=[self.pk])

    def save(self, *args, **kwargs):
        # 首次发布时补发布时间；之后改成草稿也不抹掉历史发布时间。
        if self.status == self.Status.PUBLISHED and self.published_at is None:
            self.published_at = timezone.now()
        super().save(*args, **kwargs)


class Comment(models.Model):
    """访客评论。内容默认转义后再进入模板。"""

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


class Vote(models.Model):
    """一次顶或踩。Session Key 限制同一浏览器对同一篇文章只投一次。"""

    post = models.ForeignKey(
        Post,
        verbose_name="文章",
        on_delete=models.CASCADE,
        related_name="votes",
    )
    session_key = models.CharField("浏览器标识", max_length=64, db_index=True)
    value = models.SmallIntegerField(
        "票值",
        choices=[(1, "顶"), (-1, "踩")],
    )
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "投票"
        verbose_name_plural = verbose_name
        constraints = [
            models.UniqueConstraint(fields=["post", "session_key"], name="unique_post_vote")
        ]


class Attachment(models.Model):
    """文章图片附件，图片写入阿里云 OSS。"""

    post = models.ForeignKey(
        Post,
        verbose_name="文章",
        on_delete=models.CASCADE,
        related_name="attachments",
    )
    image = models.ImageField("图片", upload_to="blog/attachments/", storage=AliyunOSSStorage())
    title = models.CharField("标题", max_length=80, blank=True)
    uploaded_by = models.ForeignKey(
        "auth.User",
        verbose_name="上传人",
        on_delete=models.CASCADE,
        related_name="attachments",
    )
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "图片附件"
        verbose_name_plural = verbose_name
        ordering = ["-created_at"]

    def __str__(self):
        return self.title or self.image.name
