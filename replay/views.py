from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from django.utils.decorators import method_decorator
from django.views import View

@method_decorator(login_required, name="dispatch")
class NewReplay(View):
  def get(self, request):
    return render(request, "replay/new.html")