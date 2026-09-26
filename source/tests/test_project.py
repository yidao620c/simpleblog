from importlib.metadata import version
from pathlib import Path

from django.core.management import call_command
from django.test import SimpleTestCase


class ProjectInitializationTests(SimpleTestCase):
    def test_django_version_is_61(self):
        self.assertEqual(version("django"), "6.1")

    def test_python_and_base_settings(self):
        self.assertEqual(Path("pyproject.toml").exists(), True)
        self.assertEqual(Path("manage.py").exists(), True)
        self.assertIn("config", __import__("config.settings", fromlist=["ROOT_URLCONF"]).ROOT_URLCONF)

    def test_manage_check_runs_without_warnings(self):
        self.assertIsNone(call_command("check"))
