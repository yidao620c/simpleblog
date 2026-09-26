---
title: 使用Django6.1开发博客（9） - 全文搜索
slug: django61-blog-09-full-text-search
date: 2026-09-26 09:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, uv ]
draft: false
---

文章多起来以后，导航只能帮人缩小范围，搜索才能直接找答案。我给首页加一个搜索框，检索标题、摘要和正文，并让搜索词跟着分页链接继续传递。

![](https://static.xiongneng.me/search-dataflow-20260926000000.png)

搜索词进入视图后先清理空格，再构造 OR 条件。只要标题、摘要或正文命中，文章就进入结果集。

## 搜索框放在每个页面都可见的位置

公共导航加入表单。

```html
<form method="get" action="{% url 'blog:list' %}" class="search-form">
  <input type="search" name="q" value="{{ query|default:'' }}" placeholder="搜索文章" aria-label="搜索文章">
  <button type="submit">搜索</button>
</form>
```

用 GET 而不是 POST。搜索没有修改数据，结果地址应该可以复制、收藏、后退和刷新。`name="q"` 很短，但语义固定，模板和视图一起使用。

输入框回填 `query`。搜完以后用户能看到自己刚才输入的词，也方便改一两个字继续搜。

## 视图里组合 OR 条件

列表视图先取已发布文章，再按关键词过滤。

```python
from django.db.models import Q

def post_list(request):
    posts = Post.published.select_related("category").prefetch_related("tags")
    query = request.GET.get("q", "").strip()
    if query:
        posts = posts.filter(
            Q(title__icontains=query)
            | Q(summary__icontains=query)
            | Q(body__icontains=query)
        )
    return render(request, "blog/post_list.html", {
        **sidebar_context(),
        "page_obj": paginate_posts(request, posts),
        "query": query,
    })
```

`Post.published` 仍然排在最前面。搜索结果绝不能把草稿带出来。

`icontains` 生成不区分大小写的包含查询。SQLite 和 PostgreSQL 都能执行，但对大量文本的效率不同。当前规模够用；等文章数量成为瓶颈，再换数据库全文索引或专门搜索服务。

空格用 `strip()` 清掉。用户输入的全是空格时，`query` 变成空字符串，页面回到普通列表，不会拿空词去查全表。

## 分页链接必须带上搜索词

搜索结果可能超过一页。分页链接只带 `page` 会让第二页丢失关键词。

```html
{% if page_obj.has_previous %}
  <a href="?q={{ query|urlencode }}&page={{ page_obj.previous_page_number }}">上一页</a>
{% endif %}
<span>第 {{ page_obj.number }} / {{ page_obj.paginator.num_pages }} 页</span>
{% if page_obj.has_next %}
  <a href="?q={{ query|urlencode }}&page={{ page_obj.next_page_number }}">下一页</a>
{% endif %}
```

`urlencode` 处理中文和特殊字符。没有它，含空格或标点的搜索词会在跳页时变形。

标题也根据有没有关键词切换。

```html
{% if query %}
  <h1>搜索：{{ query }}</h1>
{% else %}
  <h1>{{ page_title|default:"文章列表" }}</h1>
{% endif %}
```

这样读者能确认当前确实在搜索结果里。

## 测试标题、摘要和正文

在视图测试里加一条。

```python
def test_search_matches_title_summary_and_body(self):
    response = self.client.get(reverse("blog:list"), {"q": "详情页正文"})

    self.assertContains(response, "博客的第一页")
    self.assertEqual(response.context["query"], "详情页正文")
```

测试文章的标题没有「详情页正文」，摘要也没有，只有正文里有。它能证明搜索确实覆盖了正文。

再补一条草稿不参与搜索的断言更稳妥。

```python
Post.objects.create(
    title="草稿里的秘密关键词",
    slug="draft-search",
    body="搜索测试不该看到它。",
    category=self.category,
    author=self.user,
)
response = self.client.get(reverse("blog:list"), {"q": "秘密关键词"})
self.assertNotContains(response, "草稿里的秘密关键词")
```

运行完整测试。

```bash
uv run manage.py test
```

当前共 23 条测试。

```text
Ran 23 tests in 3.608s

OK
```

搜索结果页显示命中文章、搜索词和分页。

![](https://static.xiongneng.me/blog-search-results-20260926090000.png)

这个实现仍然基于 `icontains`，适合中小型博客。它没有分词，也不会按相关度打分。等到文章量、查询频率或搜索质量成为问题，再迁移到数据库全文索引或外部搜索服务。到那时，视图可以先继续接受 `q` 参数，只替换内部查询实现。
