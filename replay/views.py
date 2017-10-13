import json

from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404, redirect, render, reverse
from django.utils.decorators import method_decorator
from django.views import View

from .forms import ReplayFormYoutube
from .models import Replay, ReplayNote

@method_decorator(login_required, name="dispatch")
class New(View):
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

    replay = Replay.objects.create(title=data["title"],
      description=data["description"],
      url=data["url"],
      owner=request.user)

    return redirect(reverse("replay:watch", args=[replay.id]))


@method_decorator(login_required, name="dispatch")
class MyReplays(View):
  def get(self, request):
    return render(request, "replay/list.html", {
      "replays": Replay.objects.filter(owner=request.user).order_by("-date_created")
    })

class Watch(View):
  def get(self, request, replay_id):
    replay = get_object_or_404(Replay, pk=replay_id)
    notes = {
      replay.id: [{"time": x.time, "text": x.text} for x in ReplayNote.objects.filter(replay=replay)]
    }

    return render(request, "replay/watch.html", {
      "notes": json.dumps(notes),
      "replay": replay
    })