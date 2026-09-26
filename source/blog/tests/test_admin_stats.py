from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from ..models import Category, Post


class PostAdminStatsTests(TestCase):
    def test_changelist_shows_basic_statistics(self):
        admin = get_user_model().objects.create_superuser(username="admin", password="test-pass-123")
        category = Category.objects.create(name="Python", slug="python")
        Post.objects.create(
            title="已发布统计", slug="published-stats", category=category,
            author=admin, status=Post.Status.PUBLISHED, views=8,
        )
        Post.objects.create(
            title="草稿统计", slug="draft-stats", category=category, author=admin,
        )
        self.client.force_login(admin)

        response = self.client.get(reverse("admin:blog_post_changelist"))

        self.assertContains(response, "博客统计")
        self.assertContains(response, "文章总数：2")
        self.assertContains(response, "浏览总量：8")
