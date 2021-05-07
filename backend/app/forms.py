from django import forms
from django.contrib.gis import geos
from django.forms import ValidationError


class CoordinatesField(forms.Field):
    def clean(self, value: str):
        try:
            raw_latitude, raw_longitude = value.split(',')
            latitude = float(raw_latitude)
            longitude = float(raw_longitude)
        except ValueError: # Cant split, cant parse
            raise ValidationError('Malformed Location')
        if latitude < 0 or latitude > 90 or longitude < -180 or longitude > 180:
            raise ValidationError('Coordinates outside of legal bounds')
        return geos.Point(latitude, longitude)


class CreateMarkerForm(forms.Form):
    name = forms.CharField(label='Name', required=True, max_length=100)
    location = CoordinatesField(required=True)
