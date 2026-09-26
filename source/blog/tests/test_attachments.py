import tempfile
from pathlib import Path

from django.contrib.auth import get_user_model
from django.core.files.storage import FileSystemStorage
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase

from ..models import Attachment, Category, Post


class AttachmentTests(TestCase):
    def test_local_test_storage_can_save_image(self):
        user = get_user_model().objects.create_user(username="editor")
        category = Category.objects.create(name="Python", slug="python")
        post = Post.objects.create(title="附件测试", slug="attachment-test", category=category, author=user)
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
