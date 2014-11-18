#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: 全局处理器
Desc : 
"""
from django.db.models import Count
from .. import models
from . import utils


# 使用context processro去提供一些context内容中公共的部分，也就是返回一个字典而已。
def custom_proc(request):
    # 近期文章
    recent_posts = models.Post.objects.filter(
        published_date__isnull=False).order_by('-published_date')[:10]
    # 近期评论
    recent_comments = models.Comment.objects.order_by('-created_date')[:10]
    # 标签
    alltags = models.Tag.objects.annotate(num_post=Count('post'))
    tags = {t.name: t.num_post for t in alltags}
    # 分类目录
    categories = models.Category.objects.annotate(
        num_post=Count('post')).filter(num_post__gt=0).order_by('name')
    return {
        'RECENT_POSTS': recent_posts,
        'RECENT_COMMENTS': recent_comments,
        'TAGS': utils.tag_font(tags),
        'CATEGORIES': categories,
    }
