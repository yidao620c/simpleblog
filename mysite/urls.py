# coding=utf-8
from django.conf.urls import patterns, include, url
from django.contrib import admin

urlpatterns = [
    url('^', include('django.contrib.auth.urls')),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^search/', include('haystack.urls')),
    url(r'', include('blog.urls')),
]
