from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from datetime import datetime

from ..models import Category, Post, Tag


class PostViewTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(username="editor")
        self.category = Category.objects.create(name="Python", slug="python")
        self.post = Post.objects.create(
            title="博客的第一页",
            slug="first-page",
            summary="列表和详情已经接通。",
            body="这是详情页正文。",
            category=self.category,
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at="2026-09-25T09:00:00+08:00",
        )
        self.tag = Tag.objects.create(name="Django", slug="django")
        self.post.tags.add(self.tag)

    def test_list_shows_only_published_posts(self):
        Post.objects.create(
            title="不能出现的草稿",
            slug="hidden-draft",
            category=self.category,
            author=self.user,
        )
        response = self.client.get(reverse("blog:list"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "博客的第一页")
        self.assertNotContains(response, "不能出现的草稿")

    def test_detail_renders_and_counts_view(self):
        response = self.client.get(self.post.get_absolute_url())
        self.post.refresh_from_db()

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "这是详情页正文。")
        self.assertEqual(self.post.views, 1)

    def test_detail_renders_markdown_and_codehilite(self):
        self.post.body = "## 标题\n\n```python\nprint('hello')\n```"
        self.post.save()

        response = self.client.get(self.post.get_absolute_url())

        self.assertContains(response, "<h2>标题</h2>")
        self.assertContains(response, "codehilite")
        self.assertContains(response, "print")

    def test_draft_detail_returns_404(self):
        self.post.status = Post.Status.DRAFT
        self.post.save()

        response = self.client.get(self.post.get_absolute_url())
        self.assertEqual(response.status_code, 404)

    def test_category_tag_and_archive_pages(self):
        category_response = self.client.get(self.category.get_absolute_url())
        tag_response = self.client.get(self.tag.get_absolute_url())
        archive_response = self.client.get("/archive/2026/9/")

        self.assertContains(category_response, "博客的第一页")
        self.assertContains(tag_response, "博客的第一页")
        self.assertContains(archive_response, "博客的第一页")
        self.assertContains(category_response, "热门文章")

    def test_tag_cloud_contains_tag(self):
        response = self.client.get(reverse("blog:tags"))

        self.assertContains(response, "Django")
        self.assertContains(response, "font-size: 160%")

    def test_search_matches_title_summary_and_body(self):
        response = self.client.get(reverse("blog:list"), {"q": "详情页正文"})

        self.assertContains(response, "博客的第一页")
        self.assertEqual(response.context["query"], "详情页正文")
