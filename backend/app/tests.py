import json
from django.contrib.gis import geos
from django.test import TestCase, Client, LiveServerTestCase
from django.contrib.staticfiles.testing import StaticLiveServerTestCase
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

from . import models, views
# test posting to page
# test deleting: see the highlighted markers, check stuff goes missing
# Live server test case with Selenium, maybe with a Firefox and Chromium container

SOUTHWEST, NORTHEAST = views.INDIA_EXTENT
SW_LAT, SW_LNG = SOUTHWEST
NE_LAT, NE_LNG = NORTHEAST


class MoreWebdriver(webdriver.Remote):
    def __init__(self):
        super().__init__(command_executor="http://selenium:4444/wd/hub",
                         desired_capabilities=DesiredCapabilities.FIREFOX)
        self.implicitly_wait(1)

    def select_shadow_element_by_id(self, id):
        """Get the relevant div.
        Vue webcomponents generate the following:
        <webcomponents-foo id="id">
            #shadow root (open)
                <style type="text/css">...</style>
                <style type="text/css">...</style>
                <div>...</div>
        </webcomponents-foo>"""
        return self.execute_script('return document.getElementById("%s").shadowRoot.lastChild' % id)


class SomeTestCase(TestCase):
    def setUp(self):
        self.client = Client()


    def test_index_page_with_no_marker_shows_default_extent(self):
        self.assertEqual(1, 1)
        response = self.client.get('/')
        self.assertContains(response, json.dumps(views.INDIA_EXTENT))
        self.assertEquals(response.context['js_constants']['extent_points'], views.INDIA_EXTENT)

    def test_index_page_with_one_marker_shows_point_extent(self):
        models.Marker.objects.create(name='M1', location=geos.Point(9.65, 76.25))
        response = self.client.get('/')
        self.assertContains(response, 'M1')
        self.assertContains(response, json.dumps([[9.65, 76.25], [9.65, 76.25]]))
        self.assertEquals(response.context['js_constants']['extent_points'],
                          [[9.65, 76.25], [9.65, 76.25]])

    def test_index_page_with_two_marker_shows_full_extent(self):
        models.Marker.objects.create(name='M1', location=geos.Point(9.65, 76.25))
        models.Marker.objects.create(name='M2', location=geos.Point(9.75, 76.5))
        response = self.client.get('/')
        self.assertContains(response, 'M1')
        self.assertContains(response, 'M2')
        self.assertContains(response, json.dumps([[9.65, 76.25], [9.75, 76.5]]))
        self.assertEquals(response.context['js_constants']['extent_points'],
                          [[9.65, 76.25], [9.75, 76.5]])


class FunctionalTestCase(StaticLiveServerTestCase):
    host = 'web'

    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.browser = MoreWebdriver()

    @classmethod
    def tearDownClass(cls):
        cls.browser.quit()
        super().tearDownClass()

    def test_homepage_with_no_markers_stays_at_markers(self):
        self.browser.get(self.live_server_url)
        # After fitting bounds, wait for the following element to be rendered
        # <div id="resting-center" style="display: none;">23.28305365119609,82.50000000000001</div>
        raw_lat, raw_lng = self.browser\
            .select_shadow_element_by_id('homepage-map')\
            .find_element_by_id('resting-center')\
            .get_attribute('innerText')\
            .split(',')
        center_lat = float(raw_lat)
        center_lng = float(raw_lng)
        self.assertAlmostEquals(center_lat, (SW_LAT + NE_LAT)/2, delta=2)
        self.assertAlmostEquals(center_lng, (SW_LNG + NE_LNG)/2, delta=2)
        self.assertIn('All Markers', self.browser.title)
