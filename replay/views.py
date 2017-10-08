from django.contrib.auth.decorators import login_required
from django.shortcuts import redirect, render, reverse
from django.utils.decorators import method_decorator
from django.views import View

from .forms import ReplayFormYoutube
from .models import Replay

@method_decorator(login_required, name="dispatch")
class NewReplay(View):
  def get(self, request):
    return render(request, "replay/new.html", {
      "replay_form": ReplayFormYoutube()
    })

  def post(self, request):
    form = ReplayFormYoutube(request.POST)

    if not form.is_valid():
      return render(request, "replay/new.html", {
        "replay_form": form
      })

    data = form.cleaned_data

    Replay.objects.create(title=data["title"],
      description=data["description"],
      url=data["url"],
      owner=request.user)

    return redirect(reverse("user:home"))