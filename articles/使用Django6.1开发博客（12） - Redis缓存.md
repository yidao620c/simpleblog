---
title: 使用Django6.1开发博客（12） - Redis缓存
slug: django61-blog-12-redis-cache
date: 2026-09-26 12:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, Redis ]
draft: false
---

侧边栏在每一页都会查分类、最新文章、热门文章、最新评论和归档。这些数据不要求毫秒级新鲜，很适合缓存。我把侧边栏结果缓存一分钟；本地开发使用 LocMemCache，配置 `REDIS_URL` 后自动切到 Redis。

![](https://static.xiongneng.me/cache-sequence-20260926000000.png)

视图先查缓存；命中就直接渲染；未命中执行数据库查询，写回缓存。

## 缓存后端可切换

Django 自带 Redis 缓存后端，不需要再引入一层封装。

```python
import os

REDIS_URL = os.environ.get("REDIS_URL")

CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "blog-default",
    }
}

if REDIS_URL:
    CACHES["default"] = {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": REDIS_URL,
    }
```

本地没有 Redis 时测试仍然能跑。树莓派上用 Docker Compose 启动 Redis 后，导出一个地址即可。

```bash
export REDIS_URL=redis://192.168.1.97:6379/0
```

安装驱动。

```bash
uv add redis
```

本阶段锁定 `redis==8.1.0`。

## 只缓存已经计算好的数据

原来的 `sidebar_context()` 返回字典，里面很多值是 QuerySet。QuerySet 是惰性对象，放进缓存后再遍历仍会查数据库。所以先让它真正执行。

```python
from django.core.cache import cache
from django.db.models import Count

def sidebar_context():
    archives = list(
        Post.published
        .filter(published_at__isnull=False)
        .values("published_at__year", "published_at__month")
        .annotate(total=Count("id"))
        .order_by("-published_at__year", "-published_at__month")
    )
    return {
        "latest_posts": list(Post.published.all()[:5]),
        "popular_posts": list(Post.published.order_by("-views")[:5]),
        "recent_comments": list(Comment.objects.select_related("post")[:5]),
        "sidebar_categories": list(
            Category.objects.annotate(total=Count("posts")).filter(total__gt=0)
        ),
        "archives": archives,
    }


def cached_sidebar_context():
    return cache.get_or_set(
        "blog:sidebar:v1",
        sidebar_context,
        timeout=60,
    )
```

列表、详情、分类、标签和归档都调用 `cached_sidebar_context()`。缓存键里带 `v1`。以后字段结构变化，把版本改成 `v2`，旧缓存自然失效。

## 缓存粒度放在侧边栏

我没有缓存整页。列表页有搜索词、分页码和消息提示；详情页还会更新浏览量。整页缓存要把这些变量都纳入键，复杂度立刻上来。

侧边栏不同。它只服务导航，数据变化可以容忍几十秒延迟。缓存这一小块，收益高，风险低。

一分钟是教程阶段的保守值。真实站点可以按内容更新频率调整。如果管理员发布文章后必须马上看到侧边栏变化，就在文章保存和删除时删除这个键。

```python
from django.core.cache import cache

cache.delete("blog:sidebar:v1")
```

更彻底的做法是用信号监听 `Post`、`Category`、`Tag` 和 `Comment` 的保存删除。当前先用短过期时间，避免缓存失效逻辑先于业务逻辑变复杂。

## 用查询数证明缓存生效

Django 提供捕获查询的工具。

```python
from django.core.cache import cache
from django.db import connection
from django.test import TestCase
from django.test.utils import CaptureQueriesContext

from blog.views import cached_sidebar_context

class SidebarCacheTests(TestCase):
    def test_cached_sidebar_reuses_result(self):
        cache.clear()
        with CaptureQueriesContext(connection) as first:
            cached_sidebar_context()
        with CaptureQueriesContext(connection) as second:
            cached_sidebar_context()

        self.assertLess(len(second.captured_queries), len(first.captured_queries))
```

第一次调用会执行多条查询；第二次命中缓存，查询数应该明显减少。这个测试不关心缓存实现是 LocMem 还是 Redis，只关心 Django 缓存 API 的行为。

运行测试。

```bash
uv run manage.py test
```

本阶段共 27 条测试。

```text
Ran 27 tests in 5.167s

OK
```

缓存不是万能优化。未命中时它不减少查询，过期时还会重建数据。但它能把公共导航的开销从每页一次降到过期周期内一次。对博客来说，这一步已经值得。
