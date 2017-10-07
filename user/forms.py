from django import forms

from . import validators
from .models import User

class SignupForm(forms.ModelForm):
  class Meta:
    model = User
    fields = ["email", "username", "password"]

  email = forms.EmailField(widget=forms.EmailInput(attrs={
      "placeholder": "Email Address"
    }))

  username = forms.CharField(min_length=validators.MIN_USERNAME_LENGTH, max_length=validators.MAX_USERNAME_LENGTH, 
    widget=forms.TextInput(attrs={
      "placeholder": "Username"
    }),
    validators=validators.username)

  password = forms.CharField(min_length=6, max_length=100, 
    widget=forms.PasswordInput(attrs={
      "placeholder": "Password"
    }))

  password_confirm = forms.CharField(min_length=6, max_length=100, 
    widget=forms.PasswordInput(attrs={
      "placeholder": "Confirm Password"
    }))

  def clean(self):
    data = super(SignupForm, self).clean()
    password = data.get("password")
    password2 = data.get("password_confirm")

    if password and password2 and password != password2:
      self.add_error("password_confirm", "Passwords do not match.")


class LoginForm(forms.Form):
  username = forms.CharField(min_length=validators.MIN_USERNAME_LENGTH, max_length=validators.MAX_USERNAME_LENGTH, 
    widget=forms.TextInput(attrs={
      "placeholder": "Username"
    }),
    validators=validators.username,
    label="")

  password = forms.CharField(min_length=6, max_length=100, 
    widget=forms.PasswordInput(attrs={
      "placeholder": "Password"
    }),
    label="")

  remember = forms.BooleanField(label="Remember me", required=False)