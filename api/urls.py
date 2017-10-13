from django.conf.urls import include, url
from . import views

app_name = "api"
urlpatterns = [
  url(r'^v1/', include([
    url(r'^notes/', include([
      url(r'^new$', views.NewNote.as_view(), name="new"),
    ], "notes"))
  ]))
]