---
title: 使用Django6.1开发博客（10） - 用户认证
slug: django61-blog-10-authentication
date: 2026-09-26 10:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

评论和互动可以开放给访客；作者管理、附件上传、后台统计都需要身份。我先补上注册、登录、登出，让导航根据登录状态变化。

![](https://static.xiongneng.me/auth-sequence-20260926000000.png)

注册成功后马上建立会话；登录成功进入首页；登出只接受 POST，并回到首页。

## 注册表单扩展 Django 自带表单

不要手写密码哈希。Django 的 `UserCreationForm` 已经处理两次密码校验和密码安全规则。

```python
from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

class UserRegistrationForm(UserCreationForm):
    email = forms.EmailField(required=True)

    class Meta(UserCreationForm.Meta):
        model = User
        fields = ["username", "email"]
```

只暴露用户名和邮箱。`is_staff`、`is_superuser` 都不能让访客提交。

注册视图先挡住已登录用户。

```python
from django.contrib.auth import login

def register(request):
    if request.user.is_authenticated:
        return redirect("blog:list")
    form = UserRegistrationForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        user = form.save()
        login(request, user)
        messages.success(request, "注册成功，欢迎加入。")
        return redirect("blog:list")
    return render(request, "registration/register.html", {"form": form})
```

`form.save()` 会把密码转成哈希。视图拿到的是已创建的 `User`，再用 `login()` 建立会话。这样用户注册完不需要再走一次登录页。

登录和登出用 Django 内置视图。

```python
from django.contrib.auth.views import LoginView, LogoutView

class BlogLoginView(LoginView):
    template_name = "registration/login.html"

class BlogLogoutView(LogoutView):
    pass
```

设置里声明跳转目标。

```python
LOGIN_REDIRECT_URL = "blog:list"
LOGOUT_REDIRECT_URL = "blog:list"
```

`LoginView` 会在成功后跳到 `LOGIN_REDIRECT_URL`，也会处理 `?next=`。如果是管理员从受保护页面跳来，登录后还能回到原来的地方。

## 登出必须是 POST

Django 5 之后，`LogoutView` 只接受 POST。导航里的退出也写成表单。

```html
{% if user.is_authenticated %}
  <span>{{ user.username }}</span>
  <form method="post" action="{% url 'blog:logout' %}">
    {% csrf_token %}
    <button type="submit">退出</button>
  </form>
{% else %}
  <a href="{% url 'blog:login' %}">登录</a>
  <a href="{% url 'blog:register' %}">注册</a>
{% endif %}
```

如果退出用 GET，第三方页面可以塞一张图片或链接，让用户不经确认就被登出。POST 加 CSRF token 是更稳的边界。

登录模板继承公共骨架。

```html
{% extends "base.html" %}
{% block title %}登录{% endblock %}
{% block page %}
<section class="content auth-page">
  <h1>登录</h1>
  <form method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">登录</button>
  </form>
  <p>还没有账号？<a href="{% url 'blog:register' %}">注册</a></p>
</section>
{% endblock %}
```

注册模板结构相同，表单交给 `UserRegistrationForm`。

## 测试注册、登录、登出

注册测试检查数据库和登录提示。

```python
from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

class AuthTests(TestCase):
    def test_register_logs_user_in(self):
        response = self.client.post(reverse("blog:register"), {
            "username": "reader",
            "email": "reader@example.com",
            "password1": "strong-pass-2026",
            "password2": "strong-pass-2026",
        }, follow=True)

        self.assertContains(response, "注册成功，欢迎加入。")
        self.assertTrue(
            get_user_model().objects.filter(username="reader").exists()
        )
```

登录测试检查导航里出现用户名。

```python
def test_login_and_logout(self):
    get_user_model().objects.create_user(
        username="editor",
        password="strong-pass-2026",
    )
    response = self.client.post(reverse("blog:login"), {
        "username": "editor",
        "password": "strong-pass-2026",
    }, follow=True)
    self.assertContains(response, "editor")

    response = self.client.post(reverse("blog:logout"), follow=True)
    self.assertNotContains(response, "退出")
```

没有单独测试 Django 密码校验器的每条规则，那是框架已经保证的部分。我们要守住的是注册真的能创建用户，登录真的能建立会话，登出真的能清除状态。

运行测试。

```bash
uv run manage.py test
```

本阶段共 25 条测试。

```text
Ran 25 tests in 5.055s

OK
```

浏览器打开首页，未登录时看到登录和注册；注册后导航显示用户名和退出按钮。

![](https://static.xiongneng.me/blog-auth-navigation-20260926100000.png)

前台投稿页还没加。当前作者仍在后台创建文章；认证先把身份和会话准备好，附件上传和权限控制后面都建立在这个基础上。
