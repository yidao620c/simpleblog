from django import forms
from .models import Post


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
