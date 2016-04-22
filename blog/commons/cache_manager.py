#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: redis缓存管理器
"""
from ..models import Post
# from django.core.cache import cache
# from apscheduler.schedulers.background import BackgroundScheduler

RUNNING_TIMER = False


def clear():
    # cache.clear()
    pass


def update_click(post):
    # k = "CLICKS{:d}".format(post.id)
    # if cache.has_key(k):
    #     cache.incr(k)
    # else:
    #     cache.set(k, post.click + 1)
    # run_timer()
    pass


def get_click(post):
    # k = "CLICKS{:d}".format(post.id)
    # if cache.has_key(k):
    #     return cache.get(k)
    # else:
    #     cache.set(k, post.click)
    #     return post.click
    pass


def run_timer():
    # global RUNNING_TIMER
    # if not RUNNING_TIMER:
    #     RUNNING_TIMER = True
    #     # 30分钟同步一次文章点击率
    #     scheduler = BackgroundScheduler()
    #     scheduler.add_job(sync_click, 'interval', minutes=30)
    #     scheduler.start()
    pass


def sync_click():
    """同步文章点击数"""
    # print('同步文章点击数start....')
    # for k in cache.keys():
    #     try:
    #         p = Post.objects.get(pk=int(k[6:]))
    #         cache_click = get_click(p)
    #         if cache_click != p.click:
    #             p.click = get_click(p)
    #             p.save()
    #     except:
    #         pass
    # print('同步文章点击数end....')
    # global RUNNING_TIMER
    # RUNNING_TIMER = False
    pass
