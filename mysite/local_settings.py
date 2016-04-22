import os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
DEBUG = True
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'django',
        'USER': 'postgres',
        'PASSWORD': 'postgres',
        'HOST': '192.168.203.95',
        'PORT': '5432',
    }
}

CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://192.168.203.95:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            # 'PASSWORD': 'secretpassword',
            'PICKLE_VERSION': -1,  # Use the latest protocol version
            'SOCKET_TIMEOUT': 60,  # in seconds
            'IGNORE_EXCEPTIONS': True,
        }
    }
}
