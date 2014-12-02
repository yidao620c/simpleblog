#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: sample
Desc : 
"""
from django.apps import AppConfig
from .commons import cache_manager


class BlogAppConfig(AppConfig):
    name = 'blog'
    verbose_name = "Blog Application"

    def ready(self):
        # startup code here
        print('-------start app--------')
        cache_manager.REDIS_DB.delete('CLICKS')

