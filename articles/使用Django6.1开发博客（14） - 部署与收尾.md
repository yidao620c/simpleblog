---
title: 使用Django6.1开发博客（14） - 部署与收尾
slug: django61-blog-14-deployment
date: 2026-09-26 14:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv, Deployment ]
draft: false
---

功能已经比较完整，最后把项目放进真实运行环境。部署要收口开发阶段的假设。`DEBUG` 要关掉，密钥要交给环境，静态文件要有出口，进程要有健康检查。

![](https://static.xiongneng.me/deploy-runtime-20260926140000.png)

公共请求先到 Nginx，TLS 和静态文件在这里结束；动态请求进入 Gunicorn，再交给 Django。应用数据、附件对象和缓存分开存放，任何一块出问题都不会把所有状态混在一起。

## 让配置跟着环境走

开发时保留 `DEBUG=True` 很方便，生产环境必须显式关闭。

```python
import os

SECRET_KEY = os.environ.get(
    "DJANGO_SECRET_KEY",
    "django-insecure-local-development-key",
)
DEBUG = os.environ.get(
    "DJANGO_DEBUG",
    "true",
).lower() in {"1", "true", "yes"}

ALLOWED_HOSTS = [
    host
    for host in os.environ.get(
        "DJANGO_ALLOWED_HOSTS",
        "localhost,127.0.0.1",
    ).split(",")
    if host
]
```

默认值只服务本地开发。生产容器必须注入强随机 `DJANGO_SECRET_KEY`，并把真实域名放进 `DJANGO_ALLOWED_HOSTS`。

继续加入 CSRF 来源、静态根目录和非 DEBUG 下的安全项。

```python
STATIC_ROOT = BASE_DIR / "staticfiles"

CSRF_TRUSTED_ORIGINS = [
    origin
    for origin in os.environ.get(
        "DJANGO_CSRF_TRUSTED_ORIGINS",
        "",
    ).split(",")
    if origin
]

if not DEBUG:
    SECURE_SSL_REDIRECT = os.environ.get(
        "DJANGO_SECURE_SSL_REDIRECT",
        "true",
    ).lower() == "true"
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
```

`STATIC_ROOT` 是 `collectstatic` 的目标目录。`STATICFILES_DIRS` 则指向项目里的源静态目录；前者存收集结果，后者存源文件。

Django 6.1 的 `MAILERS` 也要随环境变化。开发用 console，生产切换到 SMTP。

```python
MAILERS = {
    "default": {
        "BACKEND": (
            "django.core.mail.backends.smtp.EmailBackend"
            if not DEBUG
            else "django.core.mail.backends.console.EmailBackend"
        ),
    },
}
```

`DJANGO_DEBUG=false` 后再执行部署检查，就能看到当前还有哪些安全项没收好。

```bash
uv run manage.py check --deploy
```

本项目的检查结果通过。

```text
System check identified no issues (0 silenced).
```

## 健康检查尽量小

负载均衡和容器平台需要知道进程是否活着。给应用加一个最小接口。

```python
from django.http import JsonResponse

def health(request):
    return JsonResponse({"status": "ok"})
```

根路由这样挂。

```python
from health import health

urlpatterns = [
    path("healthz/", health, name="health"),
    # ...
]
```

健康接口不要查数据库、Redis 和 OSS。它回答的是 WSGI 进程能否响应请求。如果把这些依赖都塞进去，某个下游短暂变慢时，负载均衡可能把本来还能服务的应用全部摘掉。

测试写成下面这样。

```python
from django.test import TestCase
from django.urls import reverse

class HealthTests(TestCase):
    def test_healthz_returns_ok(self):
        response = self.client.get(reverse("health"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok"})
```

真实浏览器访问 `/healthz/`，返回 JSON。

![](https://static.xiongneng.me/deployment-healthz-20260926082320.png)

## 收集静态文件

生产模板里仍然写 `{% static %}`，但静态文件最终要进入 `STATIC_ROOT`。

```bash
uv run manage.py collectstatic --noinput
```

本阶段收集了 132 个文件，包括项目 CSS 和 Django Admin 静态资源。

```text
132 static files copied to '.../source/staticfiles'.
```

Nginx 直接服务这些文件，不要让 Gunicorn 每次都读 CSS、JS 和图标。

```nginx
server {
    listen 80;
    server_name blog.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    http2 on;
    server_name blog.example.com;

    ssl_certificate     /etc/letsencrypt/live/blog.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/blog.example.com/privkey.pem;

    client_max_body_size 20m;

    location /static/ {
        alias /opt/blog/source/staticfiles/;
        expires 30d;
        access_log off;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

`client_max_body_size` 要大于图片上传限制。否则用户上传大图时，Nginx 会先返回 413，Django 根本没机会给出友好提示。

## 用 Gunicorn 运行

Gunicorn 加入依赖。

```bash
uv add gunicorn
```

本阶段安装的版本如下。

```text
gunicorn==26.2.0
```

启动命令如下。

```bash
uv run gunicorn config.wsgi:application \
  --bind 127.0.0.1:8000 \
  --workers 3
```

Gunicorn 在 Windows 上不能运行，这是正常现象。它依赖 Unix 的 `fcntl`，部署目标是 Linux 服务器或容器。开发与测试仍在 Windows 上使用 `runserver`。

进程数不要拍脑袋。小型博客可以从 3 个 worker 开始，观察 CPU、内存和响应时间。worker 太少会排队，太多会挤占 SQLite 或 PostgreSQL 的连接能力。

## 用容器固定运行环境

`source/Dockerfile` 使用 uv 和 Python 3.14 基础镜像。

```dockerfile
FROM ghcr.io/astral-sh/uv:python3.14-bookworm-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

COPY . .

RUN uv run python manage.py collectstatic --noinput

EXPOSE 8000
CMD ["uv", "run", "--no-sync", "gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
```

`--frozen` 保证容器只用 `uv.lock` 中锁定的版本，不会在构建时意外解析出新包。构建阶段先复制依赖清单，再复制源码，能更好利用镜像层缓存。

环境变量放进 `source/.env.example`，真实值写在本机 `.env`。

```bash
DJANGO_DEBUG=false
DJANGO_SECRET_KEY=change-me-with-64-random-characters
DJANGO_ALLOWED_HOSTS=blog.example.com
DJANGO_CSRF_TRUSTED_ORIGINS=https://blog.example.com
DJANGO_SECURE_SSL_REDIRECT=true
REDIS_URL=redis://127.0.0.1:6379/0
```

OSS 的五个变量也在里面。密钥不要写进源码，也不要复制进聊天记录。

## 数据库迁移要分两步看

部署前先检查迁移是否遗漏。

```bash
uv run manage.py makemigrations --check --dry-run
```

如果输出 `No changes detected`，说明模型和迁移一致。

然后在发布窗口执行下面这条命令。

```bash
uv run manage.py migrate
```

新迁移要先能兼容旧代码，再发布新代码；删除列、收紧约束这类不可逆变更要更谨慎。可以先把数据库结构准备好，再让新版本上线，旧代码在过渡期仍然能运行。

## 发布清单

这次收尾检查了五个部分。

```bash
uv lock --check
uv run manage.py check
uv run manage.py makemigrations --check --dry-run
uv run manage.py test
DJANGO_DEBUG=false \
DJANGO_SECRET_KEY=... \
DJANGO_ALLOWED_HOSTS=... \
uv run manage.py check --deploy
```

最终测试结果如下。

```text
Ran 31 tests in 5.007s

OK
```

最后再收集静态文件。

```bash
uv run manage.py collectstatic --noinput
```

部署配置模板也放进 `source/.env.example`。真实服务器只复制模板结构，不复制任何真实密钥。

## 部署后留下什么

开发环境可以犯错，生产环境要少给机会。DEBUG 边界、密钥来源、静态文件出口、健康检查、Gunicorn 启动方式和容器定义都已经明确。数据库、OSS 和 Redis 仍可通过环境变量替换。
