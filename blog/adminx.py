#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: xadmin
Desc : 
"""
import xadmin
from xadmin import views
from .models import Tag, Category, Post, Comment, Evaluate, Page


class AdminSettings(object):
    # 设置base_site.html的Title
    site_title = '博客管理后台'
    # 设置base_site.html的Footer
    site_footer = 'Winhong Inc.'
    menu_style = 'default'

    # 菜单设置
    def get_site_menu(self):
        return (
            {'title': '页面管理', 'perm': self.get_model_perm(Page, 'change'), 'menus': (
                {'title': '投票', 'url': self.get_model_url(Page, 'changelist')},
                {'title': '选票', 'url': self.get_model_url(Page, 'changelist')}
            )},
        )


class BaseSetting(object):
    enable_themes = True
    use_bootswatch = True


xadmin.site.register(views.BaseAdminView, BaseSetting)
xadmin.site.register(views.CommAdminView, AdminSettings)
xadmin.site.register(Tag)
xadmin.site.register(Category)
xadmin.site.register(Post)
xadmin.site.register(Comment)
xadmin.site.register(Evaluate)
xadmin.site.register(Page)

