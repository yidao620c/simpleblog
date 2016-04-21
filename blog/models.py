# coding=utf-8
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User


class Tag(models.Model):
    class Meta:
        app_label = 'blog'
        verbose_name = '标签'
        verbose_name_plural = '标签'

    name = models.CharField(max_length=40)

    def __str__(self):
        return self.name


class Category(models.Model):
    class Meta:
        app_label = 'blog'
        verbose_name = '分类目录'
        verbose_name_plural = '分类目录'

    name = models.CharField(max_length=40)

    def __str__(self):
        return self.name


class Post(models.Model):
    class Meta:
        app_label = 'blog'
        verbose_name = '文章'
        verbose_name_plural = '文章'

    # 作者
    author = models.ForeignKey(User)
    # 标题
    title = models.CharField(max_length=200)
    # 正文
    text = models.TextField()
    # 标签
    tags = models.ManyToManyField(Tag)
    # 分类目录
    category = models.ForeignKey(Category)
    # 点击量
    click = models.IntegerField(default=0)
    # 创建时间
    created_date = models.DateTimeField(default=timezone.now)
    # 发布时间
    published_date = models.DateTimeField(blank=True, null=True)

    def publish(self):
        self.published_date = timezone.now()
        self.save()

    def __str__(self):
        return self.title


class Comment(models.Model):
    class Meta:
        app_label = 'blog'
        verbose_name = '评论'
        verbose_name_plural = '评论'

    author = models.CharField(max_length=20)
    email = models.EmailField()
    text = models.TextField()
    created_date = models.DateTimeField(default=timezone.now)
    post = models.ForeignKey(Post)

    def __str__(self):
        return '{0}: {1}'.format(self.author, self.post.title)


class Evaluate(models.Model):
    class Meta:
        app_label = 'blog'
        verbose_name = '评分'
        verbose_name_plural = '评分'

    ip = models.CharField(max_length=40)
    evaluate = models.IntegerField()
    post = models.ForeignKey(Post)

    def __str__(self):
        return '{0}: {1}'.format(self.ip, self.evaluate)


class Page(models.Model):
    class Meta:
        app_label = 'blog'
        verbose_name = '页面'
        verbose_name_plural = '页面'

    # 作者
    author = models.ForeignKey(User)
    # 标题
    title = models.CharField(max_length=200)
    # 正文
    text = models.TextField()
    # 排列顺序
    porder = models.IntegerField(default=0)
    # 创建时间
    created_date = models.DateTimeField(default=timezone.now)
    # 发布时间
    published_date = models.DateTimeField(blank=True, null=True)

    def publish(self):
        self.published_date = timezone.now()
        self.save()

    def __str__(self):
        return self.title
