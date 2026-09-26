import markdown
from django import template
from django.conf import settings
from django.utils.safestring import mark_safe

register = template.Library()


@register.filter
def markdown_html(value):
    """把后台保存的 Markdown 转成 HTML；作者由 Django Admin 认证。"""

    return mark_safe(markdown.markdown(
        value,
        extensions=["fenced_code", "tables", "codehilite"],
        extension_configs={
            "codehilite": {"pygments_style": settings.PYGMENTS_STYLE}
        },
    ))
