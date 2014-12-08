#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
Topic: 过滤器filter和标签tag
Desc : 
"""
from django import template

register = template.Library()


@register.filter
def more(value, post_id):
    """通过[!--more--]标签实现文章截取和增加查看全文链接"""
    more_str = '[!--more--]'
    if more_str in value:
        return value.split(more_str)[0] + '<a href="/post/{0}">查看全文...</a>'.format(post_id)
    return value


@register.filter
def lower(value):
    return value.lower()

@register.filter
def lower(value):
    return value.lower()


@register.tag(name='more')
def do_more(parser, token):
    """
    {% more %}
        This will appear in uppercase, {{ user_name }}.
    {% endmore %}
    """
    nodelist = parser.parse(('endmore',))
    parser.delete_first_token()
    return MoreNode(nodelist)


class MoreNode(template.Node):
    def __init__(self, nodelist):
        self.nodelist = nodelist

    def render(self, context):
        output = self.nodelist.render(context)
        return output.upper()