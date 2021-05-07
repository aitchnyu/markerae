from django.urls import path, register_converter

from . import views

# Copy pasted from https://www.webforefront.com/django/accessurlparamstemplates.html
# Pattern from https://stackoverflow.com/a/4703409/604511
class FloatConverter:
    regex = '[-+]?\d*\.\d+|\d+'

    def to_python(self, value):
        return float(value)

    def to_url(self, value):
        return '{}'.format(value)

register_converter(FloatConverter, 'float')

urlpatterns = [
    path('', views.index, name='home'),
    path('markers/create/<float:latitude>/<float:longitude>', views.CreateMarker.as_view(), name='create_marker'),
    path('markers/delete/<int:marker_id>', views.DeleteMarker.as_view(), name='delete_marker'),
    path('markers/delete-markers/<int:marker_id>', views.DeleteMarkers.as_view(), name='delete_markers')
]