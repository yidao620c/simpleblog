#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: 索引配置
Desc : 
"""
from .models import Post
from haystack import indexes


class PostIndex(indexes.SearchIndex, indexes.Indexable):
    # 文章内容
    text = indexes.CharField(document=True, use_template=True)
    # 对标题字段进行索引
    title = indexes.CharField(model_attr='title')

    def get_model(self):
        return Post

    def index_queryset(self, using=None):
        return self.get_model().objects.all()
