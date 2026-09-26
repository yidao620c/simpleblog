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
        self.assertTrue(get_user_model().objects.filter(username="reader").exists())

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
