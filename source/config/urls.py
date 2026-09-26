"""
URL configuration for the blog project.
"""
from django.conf.urls.i18n import i18n_patterns
from django.contrib import admin
from django.urls import include, path

from health import health
from django.contrib import admin

from health import health
from django.conf.urls.i18n import i18n_patterns
from django.urls import include, path

urlpatterns = [
    path('healthz/', health, name='health'),
    path('i18n/', include('django.conf.urls.i18n')),
    path('admin/', admin.site.urls),
    path('', include('blog.urls')),
]


