from django.core.cache import cache
from django.db import connection
from django.test import TestCase
from django.test.utils import CaptureQueriesContext

from ..views import cached_sidebar_context


class SidebarCacheTests(TestCase):
    def test_cached_sidebar_reuses_result(self):
        cache.clear()
        with CaptureQueriesContext(connection) as first:
            cached_sidebar_context()
        with CaptureQueriesContext(connection) as second:
            cached_sidebar_context()

        self.assertLess(len(second.captured_queries), len(first.captured_queries))
