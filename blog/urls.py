from django.conf.urls import patterns, include, url
from .views import *

urlpatterns = patterns(
    '',
    url(r'^$', post_list, name='home'),
    url(r'^posts/tag/(?P<tag>\w+)$', post_list_by_tag, name='list_by_tag'),
    url(r'^posts/category/(?P<cg>\w+)$', post_list_by_category, name='list_by_cg'),
    url(r'^posts/archive/(?P<y>[0-9]{4})/(?P<m>[0-9]{1,2})$', post_list_by_ym, name='list_by_ym'),
    url(r'^post/(?P<pk>[0-9]+)/$', post_detail, name='post_detail'),
    url(r'^post/new/$', post_new, name='post_new'),
    url(r'^post/(?P<pk>[0-9]+)/edit/$', post_edit, name='post_edit'),
    url(r'^drafts/$', post_draft_list, name='post_draft_list'),
    url(r'^post/(?P<pk>[0-9]+)/publish/$', post_publish, name='post_publish'),
    url(r'^post/(?P<pk>[0-9]+)/remove/$', post_remove, name='post_remove'),
)
