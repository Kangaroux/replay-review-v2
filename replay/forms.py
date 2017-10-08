import requests

from django import forms
from django.forms import ValidationError

from . import validators
from .models import Replay

class ReplayFormBase(forms.ModelForm):
  class Meta:
    model = Replay
    fields = ["title", "description", "url"]

  title = forms.CharField(min_length=5, max_length=100, widget=forms.TextInput(attrs={
      "placeholder": "Title"
    }),
  label="")

  description = forms.CharField(max_length=500, widget=forms.Textarea(attrs={
      "placeholder": "Description (optional)",
      "rows": 4
    }),
  required=False,
  label="")


class ReplayFormYoutube(ReplayFormBase):
  url = forms.CharField(max_length=11, widget=forms.TextInput(attrs={
      "placeholder": "Youtube video ID"
    }),
  label="",
  help_text="The video ID is the code at the end of the URL.<br/>(e.g. youtube.com/watch?v=<b>DAFF2-1MPPs</b>)")

  def clean_url(self):
    data = self.cleaned_data.get("url")

    # Video ID is 11 characters
    if len(data) != 11:
      raise ValidationError("Video ID should be 11 characters.")

    # Try seeing if we can view the video. Youtube returns a 404 if the video doesn't
    # exist or is private.
    r = requests.head("https://www.youtube.com/watch?v=%s" % data)

    if not r.ok:
      raise ValidationError("Video ID is incorrect or the video is private.")

    return data