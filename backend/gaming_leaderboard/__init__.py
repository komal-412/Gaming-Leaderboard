# This will ensure that Celery is always imported when Django starts
from .celery import app as celery_app

__all__ = ('celery_app',)