from django.contrib import admin

from django.db import models
from django.db.models import Count, Sum

from .models import Attachment, Category, Comment, Post, SiteSetting, Tag


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ["title", "category", "author", "status", "published_at"]
    list_filter = ["status", "category", "tags", "author"]
    search_fields = ["title", "summary", "body"]
    prepopulated_fields = {"slug": ["title"]}
    date_hierarchy = "published_at"
    list_select_related = ["category", "author"]
    actions = ["publish_posts"]

    def changelist_view(self, request, extra_context=None):
        stats = Post.objects.aggregate(
            total=Count("id"),
            published=Count("id", filter=models.Q(status=Post.Status.PUBLISHED)),
            draft=Count("id", filter=models.Q(status=Post.Status.DRAFT)),
            views=Sum("views"),
        )
        total = stats["total"] or 1
        stats["average_views"] = (stats["views"] or 0) / total
        extra_context = {"blog_stats": stats, **(extra_context or {})}
        return super().changelist_view(request, extra_context)

    @admin.action(description="发布所选文章")
    def publish_posts(self, request, queryset):
        for post in queryset:
            post.status = Post.Status.PUBLISHED
            post.save(update_fields=["status", "published_at", "updated_at"])


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ["name", "slug", "created_at"]
    search_fields = ["name"]
    prepopulated_fields = {"slug": ["name"]}


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ["name", "slug", "created_at"]
    search_fields = ["name"]
    prepopulated_fields = {"slug": ["name"]}


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ["nickname", "post", "email", "created_at"]
    search_fields = ["nickname", "email", "body"]
    list_filter = ["created_at"]


@admin.register(SiteSetting)
class SiteSettingAdmin(admin.ModelAdmin):
    list_display = ["site_name", "page_size", "updated_at"]

    def has_add_permission(self, request):
        return not SiteSetting.objects.exists()


@admin.register(Attachment)
class AttachmentAdmin(admin.ModelAdmin):
    list_display = ["title", "post", "uploaded_by", "created_at"]
    raw_id_fields = ["post"]
