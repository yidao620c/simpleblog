from django.test import TestCase
from django.urls import reverse


class I18NTests(TestCase):
    def test_default_language_is_chinese(self):
        response = self.client.get(reverse("blog:list"))
        self.assertContains(response, "文章列表")
        self.assertContains(response, "最新文章")

    def test_user_can_switch_to_english(self):
        response = self.client.post(
            reverse("set_language"),
            {"language": "en", "next": reverse("blog:list")},
            follow=True,
        )
        self.assertContains(response, "Article list")
        self.assertContains(response, "Latest articles")
        self.assertNotContains(response, "文章列表")

    def test_language_selector_is_present(self):
        response = self.client.get(reverse("blog:list"))
        self.assertContains(response, reverse("set_language"))
        self.assertContains(response, 'value="en"')
