---
title: 使用Django6.1开发博客（13） - I18n国际化
slug: django61-blog-13-i18n
date: 2026-09-26 13:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, i18n ]
draft: false
---

博客界面已有中文文案，但语言仍写死在模板里。我把界面文案交给 Django 翻译机制，加入 LocaleMiddleware、语言目录和切换表单。读者选择 English 后，导航、列表分页和空状态会一起变化。

![](https://static.xiongneng.me/i18n-locale-flow-20260926000000.png)

请求先经过 LocaleMiddleware，它会读取 `django_language` Cookie 或 `Accept-Language`，解析出当前语言。模板再从翻译目录里取对应文案。

## 先声明支持的语言

`settings.py` 里加入语言列表和翻译目录。

```python
from django.utils.translation import gettext_lazy as _

LANGUAGE_CODE = "zh-hans"

LANGUAGES = [
    ("zh-hans", "简体中文"),
    ("en", "English"),
]

LOCALE_PATHS = [BASE_DIR / "locale"]
```

`LANGUAGE_CODE` 是默认语言。项目源码里主要写中文，所以默认值保持 `zh-hans`。`LANGUAGES` 只列真正维护过的语言，不要为了好看加入一串没有翻译文件的选项。

LocaleMiddleware 的位置很关键。

```python
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.locale.LocaleMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]
```

它要放在 SessionMiddleware 之后，因为可能读取会话和 Cookie；也要放在 CommonMiddleware 之前，让后续请求处理已经知道当前语言。

## 模板文案改用 translate

先在模板加载 `i18n`。

```html
{% load i18n %}
```

固定文案用 `translate`。

```html
<h1>{% translate "文章列表" %}</h1>
<p>{% translate "还没有已发布文章。" %}</p>
<a href="?page=2">{% translate "下一页" %}</a>
```

带变量的文案用 `blocktranslate`。

```html
{% blocktranslate with count=post.views %}
{{ count }} 次阅读
{% endblocktranslate %}
```

分页信息也可以一次传入两个变量。

```html
{% blocktranslate with number=page_obj.number total=page_obj.paginator.num_pages %}
第 {{ number }} / {{ total }} 页
{% endblocktranslate %}
```

`<html>` 的语言属性也要动态化。

```html
{% get_current_language as LANGUAGE_CODE %}
<html lang="{{ LANGUAGE_CODE }}">
```

这个属性会影响浏览器朗读、字体选择和拼写检查。它不是 SEO 装饰。

## Python 里的提示也要翻译

后台操作返回的消息不能留在模板里翻译，因为它们由视图生成。

```python
from django.utils.translation import gettext

messages.success(request, gettext("评论已提交。"))
messages.error(request, gettext("请检查昵称、邮箱和评论内容。"))
```

分类、标签和归档页标题同样处理。

```python
"page_title": gettext("分类：%(category)s") % {"category": category}
```

`%(category)s` 是命名占位符。翻译人员可以调整语序，代码仍然通过字典填值。

## 语言切换表单

Django 提供 `set_language` 视图。根路由加入下面这段。

```python
from django.conf.urls.i18n import i18n_patterns
from django.urls import include, path

urlpatterns = [
    path("i18n/", include("django.conf.urls.i18n")),
    path("admin/", admin.site.urls),
    path("", include("blog.urls")),
]
```

导航里的切换表单提交当前语言和返回地址。

```html
<form method="post" action="{% url 'set_language' %}">
  {% csrf_token %}
  <input name="next" type="hidden" value="{{ request.path }}">
  <select name="language">
    {% get_current_language as CURRENT_LANGUAGE %}
    {% get_available_languages as LANGUAGES %}
    {% get_language_info_list for LANGUAGES as languages %}
    {% for language in languages %}
      <option value="{{ language.code }}"
        {% if language.code == CURRENT_LANGUAGE %}selected{% endif %}>
        {{ language.name_local }}
      </option>
    {% endfor %}
  </select>
  <button type="submit">{% translate "切换" %}</button>
</form>
```

`next` 让用户切换语言后停留当前页。对列表页来说，这个体验比统一跳回首页好。

## 建立英文翻译目录

本项目的源码文案以中文作为 `msgid`，英文目录把它翻译成 English。`source/locale/en/LC_MESSAGES/django.po` 里的几条如下。

```po
msgid "文章列表"
msgstr "Article list"

msgid "最新文章"
msgstr "Latest articles"

msgid "还没有已发布文章。"
msgstr "No published articles yet."
```

编译成 `.mo` 后，Django 才会加载。

```bash
msgfmt -o locale/en/LC_MESSAGES/django.mo locale/en/LC_MESSAGES/django.po
```

我在开发环境用 `polib` 编译了这个文件。生产部署只 `.mo` 也可以，但仓库里保留 `.po`，以后才能继续维护翻译。

## 测试语言切换

三条测试分别确认默认语言、英文翻译和切换表单。

```python
from django.test import TestCase
from django.urls import reverse

class I18NTests(TestCase):
    def test_default_language_is_chinese(self):
        response = self.client.get(reverse("blog:list"))
        self.assertContains(response, "文章列表")

    def test_user_can_switch_to_english(self):
        response = self.client.post(
            reverse("set_language"),
            {"language": "en", "next": reverse("blog:list")},
            follow=True,
        )
        self.assertContains(response, "Article list")
        self.assertContains(response, "Latest articles")

    def test_language_selector_is_present(self):
        response = self.client.get(reverse("blog:list"))
        self.assertContains(response, reverse("set_language"))
        self.assertContains(response, 'value="en"')
```

切换测试不只检查 Cookie，也不直接调用 `translation.activate`。它让请求真正穿过 `set_language`、LocaleMiddleware 和模板渲染。

运行测试。

```bash
uv run manage.py test blog.tests.test_i18n
```

```text
Ran 3 tests in 0.026s

OK
```

选择 English 后，页面标题和导航会出现 `Article list`、`Latest articles` 等文案。

![](https://static.xiongneng.me/blog-i18n-english-20260926130000.png)

界面文案先处理到这里。文章标题和正文属于作者创作的内容，不该被机器翻译覆盖；分类和标签名称也属于数据。真要支持多语言内容时，再为这些表设计翻译表或 JSON 字段。
