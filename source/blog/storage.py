import os
from datetime import datetime
from uuid import uuid4

import oss2
from django.core.exceptions import ImproperlyConfigured
from django.core.files.storage import Storage
from django.utils.deconstruct import deconstructible


@deconstructible
class AliyunOSSStorage(Storage):
    """最小可用的阿里云 OSS 存储；密钥只从环境读取。"""

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

    def _save(self, name, content):
        ext = os.path.splitext(name)[1].lower()
        key = f"blog/attachments/{datetime.now():%Y%m%d}/{uuid4().hex}{ext}"
        self._bucket().put_object(key, content.read())
        return key

    def url(self, name):
        endpoint = os.environ.get("OSS_ENDPOINT", "").replace("https://", "").replace("http://", "")
        bucket = os.environ.get("OSS_BUCKET_NAME", "")
        return f"https://{bucket}.{endpoint}/{name}"

    def exists(self, name):
        return False
