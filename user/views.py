from django.shortcuts import render
from django.views import View

class Home(View):
  def get(self, request):
    return render(request, "home.html")


class Login(View):
  def get(self, request):
    return render(request, "login.html")

  def post(self, request):
    pass


class Signup(View):
  def get(self, request):
    return render(request, "signup.html")