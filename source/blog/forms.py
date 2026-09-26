from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

from .models import Comment


class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ["nickname", "email", "body"]
        widgets = {
            "nickname": forms.TextInput(attrs={"placeholder": "昵称", "required": True}),
            "email": forms.EmailInput(attrs={"placeholder": "邮箱", "required": True}),
            "body": forms.Textarea(attrs={"placeholder": "写下你的看法", "rows": 4, "required": True}),
        }


class UserRegistrationForm(UserCreationForm):
    email = forms.EmailField(required=True)

    class Meta(UserCreationForm.Meta):
        model = User
        fields = ["username", "email"]
