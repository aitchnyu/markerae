from django.contrib import admin
from . import models

# Register your models here.
class MarkerAdmin(admin.ModelAdmin):
    search_fields = ['name', 'location']

admin.site.register(models.Marker, MarkerAdmin)