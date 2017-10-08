from django.conf.urls import include, url
from . import views

app_name = "replay"
urlpatterns = [
  url(r'^me/$', views.MyReplays.as_view(), name="me"),
  url(r'^new/$', views.New.as_view(), name="new"),
  url(r'^w/([\w+])$', views.Watch.as_view(), name="watch"),
]