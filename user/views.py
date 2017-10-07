from django.db.utils import IntegrityError
from django.shortcuts import redirect, render, reverse
from django.views import View

from .forms import SignupForm
from .models import User

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