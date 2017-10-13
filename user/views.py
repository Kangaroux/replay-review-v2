from django.contrib.auth import authenticate, login, logout
from django.shortcuts import redirect, render, reverse
from django.views import View

from .forms import LoginForm, SignupForm
from .models import User
from replay.models import Replay

class Home(View):
  def get(self, request):
    return render(request, "home.html", {
      "replays": Replay.objects.filter().order_by("-date_created")
    })


class Login(View):
  def get(self, request):
    if request.user.is_authenticated:
      return redirect(reverse("user:home"))

    return render(request, "login.html", {
      "login_form": LoginForm()
    })

  def post(self, request):
    form = LoginForm(request.POST)

    if not form.is_valid():
      return render(request, "login.html", {
        "login_form": form
      })

    data = form.cleaned_data
    user = authenticate(request, username=data["username"], password=data["password"])

    if not user:
      form.add_error("username", "Username or password is incorrect.")

      return render(request, "login.html", {
        "login_form": form
      })

    login(request, user)

    return redirect(reverse("user:home"))


class Logout(View):
  def get(self, request):
    logout(request)

    return redirect(reverse("user:home"))


class Signup(View):
  def get(self, request):
    if request.user.is_authenticated:
      return redirect(reverse("user:home"))
      
    return render(request, "signup.html", {
      "signup_form": SignupForm()
    })

  def post(self, request):
    form = SignupForm(request.POST)

    if not form.is_valid():
      return render(request, "signup.html", {
        "signup_form": form
      })

    data = form.cleaned_data

    user = User(username=data["username"], email=data["email"])
    user.set_password(data["password"])
    user.save()

    return redirect(reverse("user:home"))