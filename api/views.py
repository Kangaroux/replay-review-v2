from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.utils.decorators import method_decorator
from django.views import View

from replay.forms import NoteForm
from replay.models import ReplayNote

@method_decorator(login_required, name="dispatch")
class NewNote(View):
  def post(self, request):
    form = NoteForm(request.POST, user=request.user)

    if not form.is_valid():
      print(form.errors)
      return JsonResponse({}, status=400)

    data = form.cleaned_data

    note = ReplayNote(author=request.user,
      replay=data["replay"],
      text=data["text"],
      time=data["time"])

    note.save()

    return JsonResponse({
      "text": note.text,
      "time": note.time,
    }, status=200)