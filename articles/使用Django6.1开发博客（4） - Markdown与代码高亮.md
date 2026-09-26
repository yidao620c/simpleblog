---
title: 使用Django6.1开发博客（4） - Markdown与代码高亮
slug: django61-blog-04-markdown-code
date: 2026-09-25 21:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, Markdown, Pygments ]
draft: false
---

上一篇文章的详情页能打开，但正文只是几行普通段落。技术博客离不开 fenced code、表格和标题层级，纯文本很快就会不够用。我接着把 Markdown 渲染接进详情页，并让代码块得到 Pygments 高亮。

![](https://static.xiongneng.me/markdown-component-pipeline-20260926000000.png)

整条链路很短。作者在后台保存 Markdown，数据库只保存原始文本；详情页请求到达时，模板过滤器把它渲染成 HTML；CodeHilite 给代码块加上类名；页面加载预生成的 Pygments CSS，浏览器完成着色。

## 先决定在哪里渲染

Markdown 有两种常见做法。一种在保存前渲染，把 HTML 存进另一列；另一种每次展示时渲染。这个阶段我选择后者。

保存前渲染能让读取路径更快，但会带来两份真相。原始 Markdown 和 HTML 必须一起迁移，Markdown 库升级、扩展调整、样式策略变化时，历史文章都要重新处理。展示时渲染虽然每次多算一点，但数据库里的 `body` 始终只有一个来源。

博客的文章量还小，读路径的这点开销可以接受。以后访问量上来了，先加缓存，或者在保存后异步刷新渲染结果；这时还不用急着改数据模型。

我还把「渲染位置」和「信任边界」分开想了一遍。展示时渲染只是一个技术选择，真正决定能不能安全使用 `mark_safe` 的是输入来源。现在 `Post.body` 的写入入口只有 Django Admin，作者必须先通过认证和权限检查。也就是说，Markdown 语法本身不会自动可信；能进入后台的人才构成信任边界。

这个前提一旦变化，方案也要跟着变化。开放注册作者时，至少要限制 HTML 标签；允许评论里写代码时，展示器必须默认转义；从外部站点导入文章时，还要清理脚本和事件属性。到那时，渲染函数可以继续复用，安全策略要按来源分开。

安装两个包。

```bash
uv add Markdown Pygments
```

本阶段锁定到的版本如下。

```text
markdown==3.10.3
pygments==2.21.0
```

`Markdown` 负责把文本转成 HTML，`Pygments` 负责识别代码语言并输出高亮类名。两者都是这个领域的成熟库，这里不需要自己写解析器。

## 写一个模板过滤器

Django 模板默认会转义变量，这是安全底线。`{{ post.body }}` 里的 `<h2>` 会显示成文本，不会变成标题。要渲染 Markdown，就必须显式告诉模板输出结果可以当作 HTML。

在 `blog/templatetags/blog_extras.py` 里建一个过滤器。

```python
import markdown
from django import template
from django.conf import settings
from django.utils.safestring import mark_safe

register = template.Library()


@register.filter
def markdown_html(value):
    """把后台保存的 Markdown 转成 HTML；作者由 Django Admin 认证。"""

    return mark_safe(markdown.markdown(
        value,
        extensions=["fenced_code", "tables", "codehilite"],
        extension_configs={
            "codehilite": {"pygments_style": settings.PYGMENTS_STYLE}
        },
    ))
```

Django 要求应用下有 `templatetags` 包，模板里加载模块名。

```html
{% load blog_extras %}
```

详情页把原来的 `linebreaks` 换掉。

```html
{% load blog_extras %}
<div class="post-body">{{ post.body|markdown_html }}</div>
```

`mark_safe` 是这个过滤器的边界。它表示这里输出的 HTML 已经来自受控内容。当前 `body` 只由登录作者在 Django Admin 里编辑，输入源是可信的。等以后开放评论或允许匿名投稿，就不能直接沿用这个判断，必须按输入来源单独处理。

三个扩展已经覆盖当前需求。`fenced_code` 处理三反引号代码块，`tables` 处理表格，`codehilite` 把代码块交给 Pygments。没有提前加目录、脚注、数学公式这些扩展，教程还没写到那些需求。

扩展名必须放在列表里，CodeHilite 还需要单独的 `extension_configs`。第一次写这段代码时，我很自然地把 `codehilite` 拼错成 `codehighlight`，页面不报错，只是代码块退化成普通 `pre`。Markdown 不会猜你想用哪个扩展，拼错就等于没有启用。

配置字典也容易写错位置。`pygments_style` 属于 `codehilite` 的配置，不能放在顶层。下面这段是最小可用的结构。

```python
extensions = ["fenced_code", "tables", "codehilite"]
extension_configs = {
    "codehilite": {"pygments_style": "default"}
}
html = markdown.markdown(text, extensions=extensions, extension_configs=extension_configs)
```

如果不确定输出，可以在 Python shell 里直接调用一次。

```python
from blog.templatetags.blog_extras import markdown_html

print(markdown_html("# 标题\n\n```python\nprint('ok')\n```"))
```

看到 `<h1>` 和 `.codehilite` 同时出现，说明两个扩展都生效。这个检查只需要几秒钟，却能避免在浏览器里反复保存文章。

## 生成高亮样式

CodeHilite 输出类名，颜色交给 CSS。下面是一个简化后的结果。

```html
<div class="codehilite">
  <pre>
    <code>
      <span class="nb">print</span>
    </code>
  </pre>
</div>
```

`nb` 会被 Pygments 样式表解释成内建函数的颜色。换一个 Pygments 风格，HTML 结构不变，只有 CSS 变化。

`settings.py` 里记录样式名。

```python
PYGMENTS_STYLE = "default"
```

再用 Pygments 生成静态 CSS。

```python
from pygments.formatters import HtmlFormatter

css = HtmlFormatter(style="default").get_style_defs(".codehilite")
with open("source/static/css/highlight.css", "w", encoding="utf-8") as file:
    file.write(css)
```

我把 CSS 预生成成文件，不打算在页面渲染时动态输出。原因是它几乎不变，放静态文件可以交给浏览器缓存，也可以在部署阶段继续压缩。`base.html` 加载它。

```html
{% load static %}
<link rel="stylesheet" href="{% static 'css/highlight.css' %}">
```

正文区域的几个元素也补一点基础样式。代码块要能横向滚动，表格要有边界，标题要和上一段拉开距离。

```css
.post-body h2 { margin-top: 2rem; }
.post-body pre { overflow: auto; border-radius: .6rem; }
.post-body table { width: 100%; border-collapse: collapse; }
.post-body th, .post-body td {
  border: 1px solid #e6e2db;
  padding: .5rem .75rem;
}
```

代码块里的长行很常见。系统命令、堆栈、URL 都可能超过屏幕宽度。如果给 `pre` 加 `white-space: normal`，代码会换行，但缩进和复制结果都会变形。所以这里保留 `overflow auto`，让长命令横向滚动。阅读稍微麻烦一点，准确性更值钱。

表格同样需要约束。Markdown 表格一多，小屏幕会被撑开。当前先把 `width` 设为 `100%`，让列宽按内容分配，后面做移动端优化时再决定哪些列隐藏或折叠。

Pygments 官方内置了很多风格。亮色页面用 `default` 最稳妥，它的对比度经过长时间使用检验，不会为了好看牺牲可读性。以后做主题切换时，可以准备亮暗两份 CSS，再根据页面属性切换。

生成 CSS 这一步可以放进脚本里，避免某台机器手工复制旧样式。下面是一个最小命令式脚本。

```python
from pathlib import Path
from pygments.formatters import HtmlFormatter

style_name = "default"
target = Path("static/css/highlight.css")
formatter = HtmlFormatter(style=style_name)
target.write_text(
    formatter.get_style_defs(".codehilite"),
    encoding="utf-8",
)
print(target, "updated", len(target.read_text(encoding="utf-8")), "chars")
```

如果以后样式名进入设置，脚本可以读取 `django.conf.settings`。但当前只有一处使用，先把命令写清楚。每次升级 Pygments 或者更换风格，重新执行一遍，再让测试检查 `.codehilite` 仍然出现。

依赖升级也有一个小坑。Markdown 库的主版本和次版本都可能调整扩展行为，Pygments 可能增加新的词法分析器。锁定版本可以保证教程稳定，长期项目则要定期读官方变更记录。升级时先在本地重建虚拟环境，再跑这 13 条测试。

```bash
uv lock --upgrade-package Markdown
uv lock --upgrade-package Pygments
uv sync
uv run manage.py test
```

这两行只升级指定包，不会顺手把 Django 也推到另一个版本。依赖更新最好一次处理一个变量。出问题时，diff 能直接指向原因。

## 测试渲染结果

上一篇文章的三条视图测试还在。现在往详情页测试里加一条 Markdown 断言。

```python
def test_detail_renders_markdown_and_codehilite(self):
    self.post.body = "## 标题\n\n```python\nprint('hello')\n```"
    self.post.save()

    response = self.client.get(self.post.get_absolute_url())

    self.assertContains(response, "<h2>标题</h2>")
    self.assertContains(response, "codehilite")
    self.assertContains(response, "print")
```

第一条断言检查 Markdown 标题真的变成了 HTML。第二条检查 CodeHilite 容器出现。第三条检查代码内容没有丢。如果过滤器悄悄退出，或者扩展名拼错，测试会直接失败。

这个测试不验证每一个颜色类。Pygments 自己已经测试过语法高亮，我们要守住的是集成点，也就是请求进入视图后，正文确实经过了 Markdown 管道。

这里也不用前端 Markdown 库。把渲染放在服务端有几个直接好处。第一，文章 HTML 可以保持稳定，用户浏览器不支持某些功能也不影响正文。第二，搜索和缓存都能工作在渲染后的结果上。第三，页面不需要再为了正文加载一套解析器。

前端只负责展示，也意味着代码高亮不依赖 JavaScript。Pygments 的 CSS 加载完成后，颜色已经在了。页面滚动、字体加载或脚本失败，都不会让代码块突然变成灰白。

服务端渲染还有一个副产品。正文 HTML 在响应里已经成形，以后做站点地图、RSS、邮件摘要或者全文索引时，可以复用同一条生成路径。虽然本阶段还没有这些功能，但不用为它们改模型。

当然，展示时渲染也不是无限便宜的。一篇几万字的文章每次请求都重新解析，会浪费 CPU。合理的第一步是先量化。等详情页出现真实访问量后，可以给单篇文章加缓存，键里带上文章主键和更新时间。缓存失效的信号已经有了，就是 `updated_at`。

这个设计也带来一个副产品。Markdown 源文本永远是数据库里的权威内容。缓存可以被清掉，渲染结果可以被重算，正文本身不需要迁移。

第一次跑这个测试时，页面输出全是转义后的 `&lt;h2&gt;`。原因很典型。Django 模板默认不信任任何变量，`markdown.markdown()` 返回的 HTML 又被自动转义了一层。加 `mark_safe` 以后，测试变绿。安全机制没有坏，只是这里需要显式声明信任边界。

这类问题很适合用测试暴露。肉眼看页面时，注意力容易被标题和颜色吸引，真正生成 HTML 的过程反而被跳过。断言 `<h2>标题</h2>` 后，任何一层意外转义都会被抓住。

如果以后要升级 Markdown 库，这组测试也能当回归检查。新版本可能更严格地处理空行、缩进或内联 HTML，旧文章里某些写法可能产生不同结构。先让测试跑过，再抽查几篇代表性文章，比直接部署后再等读者反馈稳妥。

现在启动服务，打开一篇带代码的文章。

```bash
uv run manage.py runserver 127.0.0.1:8000
```

详情页里的标题、列表、表格和代码块会按各自元素展示。

![](https://static.xiongneng.me/markdown-code-detail-20260925200000.png)

提交前仍然跑完整清单。

```bash
uv lock --check
uv run manage.py check
uv run manage.py makemigrations --check --dry-run
uv run manage.py test
```

本阶段共 13 条测试。

```text
Ran 13 tests in 3.028s

OK
```

数据库不需要迁移，因为 `body` 从一开始就是 `TextField`。Markdown 属于展示能力，不改文章数据的形状；变化集中在外部依赖、模板过滤器和静态样式里。
