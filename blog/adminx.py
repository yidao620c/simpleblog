#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: xadmin
Desc : 
"""
import xadmin
from .models import Tag, Category, Post, Comment, Evaluate

xadmin.site.register(Tag)
xadmin.site.register(Category)
xadmin.site.register(Post)
xadmin.site.register(Comment)
xadmin.site.register(Evaluate)

