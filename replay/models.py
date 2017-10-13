from django.db import models

class Replay(models.Model):
  SOURCE_YOUTUBE = "YT"

  SOURCES = (
    (SOURCE_YOUTUBE, "Youtube"),
  )

  date_created = models.DateTimeField(auto_now_add=True)
  owner = models.ForeignKey("user.User")

  title = models.CharField(max_length=100)
  description = models.TextField(max_length=500, blank=True)

  # The URL where the video is stored
  url = models.CharField(max_length=200)

  source = models.CharField(max_length=2, choices=SOURCES, default=SOURCE_YOUTUBE)


class ReplayNote(models.Model):
  date_created = models.DateTimeField(auto_now_add=True)
  date_updated = models.DateTimeField(auto_now=True)

  replay = models.ForeignKey("Replay")
  author = models.ForeignKey("user.User")

  text = models.TextField(max_length=500)
  time = models.FloatField()