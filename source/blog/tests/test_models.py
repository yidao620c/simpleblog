from django.contrib.auth import get_user_model
from django.test import TestCase
from django.utils import timezone

from ..models import Category, Post, Tag


class PostModelTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(
            username="editor",
            password="test-pass-123",
        )
        self.category = Category.objects.create(name="Python", slug="python")
        self.tag = Tag.objects.create(name="Django", slug="django")

    def test_model_str_and_relations(self):
        post = Post.objects.create(
            title="Django 模型入门",
            slug="django-models",
            body="模型是博客数据的骨架。",
            category=self.category,
            author=self.user,
        )
        post.tags.add(self.tag)

        self.assertEqual(str(post), "Django 模型入门")
        self.assertEqual(str(self.category), "Python")
        self.assertEqual(str(self.tag), "Django")
        self.assertEqual(self.category.posts.count(), 1)
        self.assertEqual(self.tag.posts.count(), 1)

    def test_draft_is_not_in_published_manager(self):
        Post.objects.create(
            title="草稿文章",
            slug="draft-post",
            body="还没准备好。",
            category=self.category,
            author=self.user,
        )
        published = Post.objects.create(
            title="已发布文章",
            slug="published-post",
            body="可以给读者看了。",
            category=self.category,
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at=timezone.now(),
        )

        self.assertEqual(Post.objects.count(), 2)
        self.assertEqual(Post.published.count(), 1)
        self.assertEqual(Post.published.first(), published)

    def test_first_publish_sets_published_at(self):
        post = Post.objects.create(
            title="自动记录发布时间",
            slug="auto-publish-time",
            body="发布时间应该由系统维护。",
            category=self.category,
            author=self.user,
        )
        self.assertIsNone(post.published_at)

        post.status = Post.Status.PUBLISHED
        post.save()
        post.refresh_from_db()

        self.assertIsNotNone(post.published_at)
