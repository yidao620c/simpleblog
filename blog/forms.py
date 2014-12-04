# coding=utf-8
from django import forms
from .models import Post, Comment


class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ('title', 'text', 'category')
        labels = {
            'category': '分类目录',
            'text': '正文',
            'title': '标题',
        }
        widgets = {
            'text': forms.Textarea(attrs={'rows': 15}),
        }


class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ('author', 'email', 'text')
        labels = {
            'author': '昵称(必填)',
            'email': '电子邮箱(我们会为您保密)(必填)',
            'text': '评论内容',
        }
        widgets = {
            'text': forms.Textarea(attrs={'rows': 7}),
        }