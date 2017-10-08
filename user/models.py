from django.contrib.auth.models import AbstractUser
from django.db import models

from .validators import MAX_USERNAME_LENGTH

class User(AbstractUser):
  username = models.SlugField(max_length=MAX_USERNAME_LENGTH, unique=True,
    error_messages={
      'unique': "Username is already taken.",
    })
  email = models.EmailField(unique=True,
    error_messages={
      'unique': "Email is already in use.",
    })