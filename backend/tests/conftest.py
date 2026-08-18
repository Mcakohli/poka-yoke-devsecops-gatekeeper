import django
from django.conf import settings

def pytest_configure():
    if not settings.configured:
        settings.configure(
            SECRET_KEY="poka-yoke-devsecops-test-secret-key",
            INSTALLED_APPS=[
                "rest_framework",
            ],
            DATABASES={
                "default": {
                    "ENGINE": "django.db.backends.sqlite3",
                    "NAME": ":memory:",
                }
            },
        )
        django.setup()
