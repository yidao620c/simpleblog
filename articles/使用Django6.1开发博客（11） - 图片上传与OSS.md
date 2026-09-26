---
title: 使用Django6.1开发博客（11） - 图片上传与OSS
slug: django61-blog-11-oss-uploads
date: 2026-09-26 11:00:00 +0800
toc: true
categories: [ python ]
tags: [ Django, Django6.1, Python, OSS ]
draft: false
---

博客经常需要给文章配图。我加入图片附件模型，并把图片写入阿里云 OSS。五个配置全部来自环境变量，密钥不写进代码。

![](https://static.xiongneng.me/oss-deployment-20260926000000.png)

上传链路是 Django 收文件，`ImageField` 校验图片，自定义 Storage 调用 OSS SDK，数据库只保存对象键。

## 自定义 Storage

新建 `blog/storage.py`，继承 `django.core.files.storage.Storage`。

```python
import os
import oss2
from django.core.exceptions import ImproperlyConfigured
from django.core.files.storage import Storage
from django.utils.deconstruct import deconstructible

@deconstructible
class AliyunOSSStorage(Storage):
    def _config(self):
        keys = ["OSS_ACCESS_KEY_ID", "OSS_ACCESS_KEY_SECRET", "OSS_BUCKET_NAME", "OSS_ENDPOINT", "OSS_REGION"]
        values = {key: os.environ.get(key) for key in keys}
        missing = [key for key, value in values.items() if not value]
        if missing:
            raise ImproperlyConfigured("缺少 OSS 环境变量：" + ", ".join(missing))
        return values

    def _bucket(self):
        config = self._config()
        auth = oss2.ProviderAuthV4(oss2.credentials.EnvironmentVariableCredentialsProvider())
        endpoint = config["OSS_ENDPOINT"]
        if not endpoint.startswith(("http://", "https://")):
            endpoint = "https://" + endpoint
        return oss2.Bucket(auth, endpoint, config["OSS_BUCKET_NAME"], region=config["OSS_REGION"])
```

`@deconstructible` 不能少。没有它，Django 生成迁移时无法序列化 `storage=AliyunOSSStorage()`。

保存文件时生成新对象键。

```python
from datetime import datetime
from uuid import uuid4

def _save(self, name, content):
    ext = os.path.splitext(name)[1].lower()
    key = f"blog/attachments/{datetime.now():%Y%m%d}/{uuid4().hex}{ext}"
    self._bucket().put_object(key, content.read())
    return key
```

用 UUID 命名可以避免覆盖。原文件名不再出现在对象键里，数据库里的 `title` 负责给人看。

## 附件模型和后台

```python
from django.db import models
from .storage import AliyunOSSStorage

class Attachment(models.Model):
    post = models.ForeignKey(
        Post, verbose_name="文章", on_delete=models.CASCADE,
        related_name="attachments",
    )
    image = models.ImageField(
        "图片", upload_to="blog/attachments/", storage=AliyunOSSStorage()
    )
    title = models.CharField("标题", max_length=80, blank=True)
    uploaded_by = models.ForeignKey(
        "auth.User", verbose_name="上传人", on_delete=models.CASCADE
    )
    created_at = models.DateTimeField("创建时间", auto_now_add=True)
```

`ImageField` 会检查上传内容能不能作为图片打开。`post` 用 `PROTECT` 也可以，这里选择 `CASCADE`，表示附件是文章的一部分。

Admin 注册很直接。

```python
@admin.register(Attachment)
class AttachmentAdmin(admin.ModelAdmin):
    list_display = ["title", "post", "uploaded_by", "created_at"]
    raw_id_fields = ["post"]
```

详情页展示附件。

```html
{% if post.attachments.all %}
  <div class="attachments">
    {% for attachment in post.attachments.all %}
      <figure>
        <img src="{{ attachment.image.url }}" alt="{{ attachment.title|default:attachment.image.name }}">
        {% if attachment.title %}<figcaption>{{ attachment.title }}</figcaption>{% endif %}
      </figure>
    {% endfor %}
  </div>
{% endif %}
```

## 测试时不请求阿里云

测试用本地 `FileSystemStorage` 替换字段上的存储，验证 Django 模型和上传流程。

```python
from django.core.files.storage import FileSystemStorage
from django.core.files.uploadedfile import SimpleUploadedFile

png = bytes.fromhex("89504e470d0a1a0a0000000d49484452000000010000000108060000001f15c4890000000a49444154789c6300010000050001")
original = Attachment._meta.get_field("image").storage
with tempfile.TemporaryDirectory() as root:
    Attachment._meta.get_field("image").storage = FileSystemStorage(location=root)
    try:
        attachment = Attachment.objects.create(
            post=post,
            uploaded_by=user,
            title="结构图",
            image=SimpleUploadedFile("diagram.png", png, content_type="image/png"),
        )
        self.assertTrue(Path(attachment.image.path).exists())
    finally:
        Attachment._meta.get_field("image").storage = original
```

真实上传由 OSS SDK 完成，单元测试不重复测试 SDK。它要证明的是模型、字段和存储接口接得正确。

运行迁移和测试。

```bash
uv add Pillow oss2
uv run manage.py makemigrations blog
uv run manage.py migrate
uv run manage.py test
```

迁移输出如下。

```text
Migrations for 'blog':
  blog\migrations\0005_attachment.py
    + Create model Attachment
```

测试结果如下。

```text
Ran 26 tests in 5.135s

OK
```

运行前导出五个环境变量。`.env` 不进入 Git。

```bash
export OSS_ACCESS_KEY_ID=...
export OSS_ACCESS_KEY_SECRET=...
export OSS_BUCKET_NAME=...
export OSS_ENDPOINT=...
export OSS_REGION=...
```

图片上传到 OSS 后，详情页只引用远端 URL。Django 进程不长期保存文件，也不把桶地址和密钥混进数据库。
