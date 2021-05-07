from django.contrib.gis.db import models


class Marker(models.Model):
    name = models.TextField()
    location = models.PointField()

    def __str__(self):
        return self.name
