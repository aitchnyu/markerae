from django.contrib.gis.db.models import Extent, Union
from django.http import HttpResponse
from django.shortcuts import render, redirect, reverse
from django.views import View

from . import forms, models

def index(request):
    query = models.Marker.objects.order_by('-id')
    lower_left_lat, lower_left_lng, upper_right_lat, upper_right_lng = query.aggregate(Extent('location'))['location__extent']
    extent_points = [[lower_left_lat, lower_left_lng], [upper_right_lat, upper_right_lng]]
    markers = [{'id': marker.id,
                 'location': {'lat': marker.location.x, 'lng': marker.location.y}, # Yes, this is inverted
                 'name': marker.name}
                for marker in query]
    return render(request, 'app/home.html', {'js_constants': {'markers': markers, 'extent_points': extent_points}})


class CreateMarker(View):
    def get(self, request, latitude, longitude):
        form = forms.CreateMarkerForm(initial={'location': f'{latitude},{longitude}'})
        return render(request,
                      'app/create_marker.html',
                      {'form': form, 'latitude': latitude, 'longitude': longitude})

    def post(self, request, latitude, longitude):
        form = forms.CreateMarkerForm(request.POST)
        if not form.is_valid():
            return render(request,
                          'app/create_marker.html',
                          {'form': form, 'latitude': latitude, 'longitude': longitude})
        models.Marker.objects.create(
            name=form.cleaned_data['name'],
            location=form.cleaned_data['location'])
        return redirect(reverse('home'))


class DeleteMarker(View):
    def get(self, request, marker_id):
        marker = models.Marker.objects.get(id=marker_id)
        return render(request,
                      'app/delete_marker.html',
                      {'marker': marker})

    def post(self, request, marker_id):
        marker = models.Marker.objects.filter(id=marker_id)
        marker.delete()
        return redirect(reverse('home'))


class DeleteMarkers(View):
    def get(self, request, marker_id):
        markers = models.Marker.objects.filter(id__lte=marker_id)
        return render(request,
                      'app/delete_markers.html',
                      {'markers': markers, 'marker_id': marker_id})

    def post(self, request, marker_id):
        models.Marker.objects.filter(id__lte=marker_id).delete()
        return redirect(reverse('home'))
