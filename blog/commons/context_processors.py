#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: 全局处理器
Desc : 
"""
from django.template import loader, RequestContext
from django.http import HttpResponse


# 使用context processro去提供一些context内容中公共的部分，也就是返回一个字典而已。
def custom_proc(request):
    return {
        'app': 'My app',
        'user': request.user,
        'ip_address': request.META['REMOTE_ADDR']
    }

