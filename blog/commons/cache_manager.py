#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: redis缓存管理器
"""
from ..models import Post
from redis_cache import get_redis_connection
from apscheduler.schedulers.background import BackgroundScheduler

RUNNING_TIMER = False
REDIS_DB = get_redis_connection('default')


def update_click(post):
    if REDIS_DB.hexists("CLICKS", post.id):
        print('REDIS_DB.hexists...' + str(post.id))
        REDIS_DB.hincrby('CLICKS', post.id)
    else:
        print('REDIS_DB.not_hexists...' + str(post.id))
        REDIS_DB.hset('CLICKS', post.id, post.click + 1)
    run_timer()


def get_click(post):
    if REDIS_DB.hexists("CLICKS", post.id):
        return REDIS_DB.hget('CLICKS', post.id)
    else:
        REDIS_DB.hset('CLICKS', post.id, post.click)
        return post.click


def run_timer():
    global RUNNING_TIMER
    if not RUNNING_TIMER:
        RUNNING_TIMER = True
        # 30分钟同步一次文章点击率
        scheduler = BackgroundScheduler()
        scheduler.add_job(sync_click, 'interval', minutes=30)
        scheduler.start()


def sync_click():
    """同步文章点击数"""
    print('同步文章点击数start....')
    for k in REDIS_DB.hkeys('CLICKS'):
        try:
            p = Post.objects.get(pk=k)
            cache_click = get_click(p)
            if cache_click != p.click:
                p.click = get_click(p)
                p.save()
        except:
            pass
    print('同步文章点击数end....')


