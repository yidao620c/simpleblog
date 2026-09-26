from django.contrib.auth import get_user_model
from django.core.cache import cache
from django.test import TestCase
from django.urls import reverse

from ..models import Category, Post, SiteSetting


class PaginationTests(TestCase):
    def setUp(self):
        cache.clear()
        self.user = get_user_model().objects.create_user(username="editor")
        self.category = Category.objects.create(name="Python", slug="python")
        for number in range(1, 4):
            Post.objects.create(
                title=f"第 {number} 篇文章",
                slug=f"post-{number}",
                category=self.category,
                author=self.user,
                status=Post.Status.PUBLISHED,
                published_at=f"2026-09-0{number}T09:00:00+08:00",
            )

    def test_admin_can_change_page_size(self):
        setting = SiteSetting.load()
        setting.page_size = 2
        setting.save()

        first = self.client.get(reverse("blog:list"))
        second = self.client.get(reverse("blog:list"), {"page": 2})

        self.assertEqual([post.title for post in first.context["page_obj"]], ["第 3 篇文章", "第 2 篇文章"])
        self.assertContains(first, "第 3 篇文章")
        self.assertContains(second, "第 2 篇文章")
        self.assertContains(second, "第 2 / 2 页")

    def test_invalid_page_falls_back_to_valid_page(self):
        setting = SiteSetting.load()
        setting.page_size = 2
        setting.save()

        response = self.client.get(reverse("blog:list"), {"page": "999"})
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "第 2 / 2 页")
