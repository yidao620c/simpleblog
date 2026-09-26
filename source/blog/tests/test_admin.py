from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from ..models import Category, Post, Tag


class PostAdminTests(TestCase):
    def setUp(self):
        self.admin = get_user_model().objects.create_superuser(
            username="admin",
            password="test-pass-123",
            email="admin@example.com",
        )
        self.category = Category.objects.create(name="Python", slug="python")
        self.tag = Tag.objects.create(name="Django", slug="django")
        self.post = Post.objects.create(
            title="后台模型测试",
            slug="admin-model-test",
            body="用于检查 Django Admin。",
            category=self.category,
            author=self.admin,
        )
        self.post.tags.add(self.tag)
        self.client.force_login(self.admin)

    def test_blog_models_are_registered(self):
        response = self.client.get(reverse("admin:index"))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "文章")
        self.assertContains(response, "分类")
        self.assertContains(response, "标签")

    def test_post_changelist_and_search(self):
        response = self.client.get(reverse("admin:blog_post_changelist"), {"q": "后台"})

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "后台模型测试")
        self.assertContains(response, "Python")

    def test_publish_action_updates_selected_posts(self):
        url = reverse("admin:blog_post_changelist")
        data = {
            "action": "publish_posts",
            "index": 0,
            "_selected_action": [str(self.post.pk)],
        }

        response = self.client.post(url, data, follow=True)
        self.post.refresh_from_db()

        self.assertEqual(response.status_code, 200)
        self.assertEqual(self.post.status, Post.Status.PUBLISHED)
        self.assertIsNotNone(self.post.published_at)
