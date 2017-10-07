from django.conf.urls import url
from . import views

app_name = "user"
urlpatterns = [
  url(r'^$', views.Home.as_view(), name="home"),
  url(r'^login/$', views.Login.as_view(), name="login"),
  url(r'^logout/$', views.Logout.as_view(), name="logout"),
  url(r'^signup/$', views.Signup.as_view(), name="signup"),
]