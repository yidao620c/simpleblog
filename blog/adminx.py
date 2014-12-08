#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: adminx定制类
Desc :
"""
import xadmin
import xadmin.views as xviews
from .models import Tag, Category, Post, Comment, Evaluate, Page
from xadmin.layout import Main, TabHolder, Tab, Fieldset, Row, Col, AppendedText, Side

class MainDashboard(object):
    widgets = [
        [
            {"type": "html", "title": "Test Widget", "content": "<h3> Welcome to Xadmin! </h3><p>Join Online Group: <br/>QQ Qun : 282936295</p>"},
            {"type": "chart", "model": "app.accessrecord", 'chart': 'user_count', 'params': {'_p_date__gte': '2013-01-08', 'p': 1, '_p_date__lt': '2013-01-29'}},
            {"type": "list", "model": "app.host", 'params': {
                'o':'-guarantee_date'}},
        ],
        [
            {"type": "qbutton", "title": "Quick Start", "btns": [{'model': Post}, {'model':Comment}, {'title': "Google", 'url': "http://www.google.com"}]},
            {"type": "addform", "model": Page},
        ]
    ]
xadmin.site.register(xviews.IndexView, MainDashboard)

class BaseSetting(object):
    enable_themes = True
    use_bootswatch = True
xadmin.site.register(xviews.BaseAdminView, BaseSetting)


class AdminSettings(object):
    # 设置base_site.html的Title
    site_title = '博客管理后台'
    # 设置base_site.html的Footer
    site_footer = 'Winhong Inc.'
    menu_style = 'default'

    # 菜单设置
    def get_site_menu(self):
        return (
            {'title': '博客管理', 'perm': self.get_model_perm(Page, 'change'), 'menus': (
                {'title': '所有页面', 'icon': 'fa fa-vimeo-square'
                    , 'url': self.get_model_url(Page, 'changelist')},
                {'title': '分类目录', 'icon': 'fa fa-vimeo-square'
                    , 'url': self.get_model_url(Category, 'changelist')},
            )},
        )
xadmin.site.register(xviews.CommAdminView, AdminSettings)

xadmin.site.register(Page)
xadmin.site.register(Category)
# xadmin.site.register(Tag)
# xadmin.site.register(Post)
# xadmin.site.register(Comment)
# xadmin.site.register(Evaluate)

