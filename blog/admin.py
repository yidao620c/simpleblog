from django.contrib import admin
from .models import Tag, Category, Post, Comment

admin.site.register(Tag)
admin.site.register(Category)
admin.site.register(Post)
admin.site.register(Comment)
