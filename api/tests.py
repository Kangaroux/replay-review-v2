from django.shortcuts import reverse
from django.test import TestCase

from replay.models import Replay, ReplayNote
from user.models import User

class TestNewNote(TestCase):
  def setUp(self):
    self.user = User(username="test", email="test@test.com", password="qwerty54321")
    self.user.save()

    self.replay = Replay(owner=self.user, title="My Replay", url="aaaaaaaaa")
    self.replay.save()

    self.client.force_login(self.user)

  def tearDown(self):
    self.client.logout()

  def test_ok(self):
    time = 5.0
    text = "my note text wooo"
    
    r = self.client.post(reverse("api:notes:new"), {
      "replay": self.replay.id,
      "time": time,
      "text": text
    })

    self.assertEqual(r.status_code, 200)

    j = r.json()

    self.assertEqual(j["text"], text)
    self.assertEqual(j["time"], time)

    self.assertTrue(ReplayNote.objects.filter(text=text, time=time).exists())