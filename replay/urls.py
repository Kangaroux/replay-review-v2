from django.conf.urls import url
from . import views

app_name = "replay"
urlpatterns = [
  url(r'^new/$', views.NewReplay.as_view(), name="new"),
]