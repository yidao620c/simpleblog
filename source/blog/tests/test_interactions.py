from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse

from ..models import Category, Comment, Post, Vote


class InteractionTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(username="editor")
        self.category = Category.objects.create(name="Python", slug="python")
        self.post = Post.objects.create(
            title="可以互动的文章",
            slug="interactive-post",
            body="试着评论和投票。",
            category=self.category,
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at="2026-09-25T09:00:00+08:00",
        )

    def test_comment_can_be_created_and_is_escaped(self):
        response = self.client.post(reverse("blog:comment", args=[self.post.pk]), {
            "nickname": "小明",
            "email": "ming@example.com",
            "body": "<script>alert(1)</script>这条评论很有用。",
        }, follow=True)

        self.assertContains(response, "评论已提交。")
        self.assertContains(response, "&lt;script&gt;")
        self.assertNotContains(response, "<script>alert(1)</script>")
        self.assertEqual(Comment.objects.count(), 1)

    def test_invalid_comment_is_not_saved(self):
        response = self.client.post(reverse("blog:comment", args=[self.post.pk]), {
            "nickname": "",
            "email": "bad-email",
            "body": "",
        }, follow=True)

        self.assertContains(response, "请检查昵称、邮箱和评论内容。")
        self.assertEqual(Comment.objects.count(), 0)

    def test_vote_once_per_session(self):
        url = reverse("blog:vote", args=[self.post.pk, 1])
        self.client.post(url)
        self.client.post(url)

        self.post.refresh_from_db()
        self.assertEqual(self.post.likes, 1)
        self.assertEqual(Vote.objects.count(), 1)

    def test_popular_posts_are_ordered_by_views(self):
        second = Post.objects.create(
            title="更热门的文章",
            slug="more-popular",
            category=self.category,
            author=self.user,
            status=Post.Status.PUBLISHED,
            published_at="2026-09-25T09:00:00+08:00",
            views=5,
        )
        self.post.views = 1
        self.post.save()

        response = self.client.get(reverse("blog:list"))
        content = response.content.decode()

        self.assertLess(content.index(second.title), content.index(self.post.title))
