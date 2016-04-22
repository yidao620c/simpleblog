#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: sample
Desc : 
"""
from django.apps import AppConfig
from django.core.cache import cache


class BlogAppConfig(AppConfig):
    name = 'blog'
    verbose_name = "Blog Application"

    def ready(self):
        # startup code here
        print('-------start app--------')
        cache.clear()

