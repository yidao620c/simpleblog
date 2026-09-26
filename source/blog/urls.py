from django.urls import path

from . import views

app_name = "blog"

urlpatterns = [
    path("", views.post_list, name="list"),
    path("post/<int:pk>/", views.post_detail, name="detail"),
    path("post/<int:pk>/comment/", views.add_comment, name="comment"),
    path("post/<int:pk>/vote/<int:value>/", views.vote, name="vote"),
    path("account/register/", views.register, name="register"),
    path("account/login/", views.BlogLoginView.as_view(), name="login"),
    path("account/logout/", views.BlogLogoutView.as_view(), name="logout"),
    path("category/<slug:slug>/", views.category_posts, name="category"),
    path("tag/<slug:slug>/", views.tag_posts, name="tag"),
    path("tags/", views.tag_cloud, name="tags"),
    path("archive/<int:year>/<int:month>/", views.archive_posts, name="archive"),
]
