# coding=utf-8
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.utils.encoding import python_2_unicode_compatible


@python_2_unicode_compatible
class Tag(models.Model):
    class Meta:
        verbose_name = u'标签'
        verbose_name_plural = u'标签'

    name = models.CharField(max_length=40)

    def __str__(self):
        return self.name


@python_2_unicode_compatible
class Category(models.Model):
    class Meta:
        verbose_name = u'分类目录'
        verbose_name_plural = u'分类目录'

    name = models.CharField(max_length=40)

    def __str__(self):
        return self.name



@python_2_unicode_compatible
class Post(models.Model):
    class Meta:
        verbose_name = u'文章'
        verbose_name_plural = u'文章'
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



@python_2_unicode_compatible
class Comment(models.Model):
    class Meta:
        verbose_name = u'评论'
        verbose_name_plural = u'评论'
    author = models.CharField(max_length=20)
    email = models.EmailField()
    text = models.TextField()
    created_date = models.DateTimeField(default=timezone.now)
    post = models.ForeignKey(Post)

    def __str__(self):
        return '{0}: {1}'.format(self.author, self.post.title)


@python_2_unicode_compatible
class Evaluate(models.Model):
    class Meta:
        verbose_name = u'评分'
        verbose_name_plural = u'评分'
    ip = models.CharField(max_length=40)
    evaluate = models.IntegerField()
    post = models.ForeignKey(Post)

    def __str__(self):
        return '{0}: {1}'.format(self.ip, self.evaluate)


@python_2_unicode_compatible
class Page(models.Model):
    class Meta:
        verbose_name = u'页面'
        verbose_name_plural = u'页面'
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
