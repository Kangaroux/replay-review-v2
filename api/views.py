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

    print("created a note")

    return JsonResponse({
      "id": note.id,
      "text": note.text,
      "time": note.time,
    }, status=200)


@method_decorator(login_required, name="dispatch")
class DeleteNote(View):
  def post(self, request):
    note_id = request.POST.get("note_id")
    replay_id = request.POST.get("replay_id")

    if note_id is None or replay_id is None:
      return JsonResponse({}, status=400)

    try:
      note_id = int(note_id)
      replay_id = int(replay_id)
    except ValueError:
      return JsonResponse({}, status=400)

    note = ReplayNote.objects.filter(pk=note_id, author=request.user).first()

    # Note doesn't exist or doesn't match the replay id
    if not note or note.replay.id != replay_id:
      return JsonResponse({}, status=400)

    note.delete()

    print("deleted a note")

    return JsonResponse({}, status=200)