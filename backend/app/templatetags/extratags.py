import json

from django import template
from django.conf import settings
from django.core.serializers.json import DjangoJSONEncoder
from django.http import QueryDict
from django.utils.http import urlencode

register = template.Library()


@register.simple_tag
def hcaptcha_sitekey():
    return settings.HCAPTCHA_SITEKEY

@register.filter
def js_constants_def(value):
    encoded = json.dumps(value, cls=DjangoJSONEncoder).replace("\"", "\\\"")
    return f"""let CONSTANTS = JSON.parse("{encoded}")"""


@register.filter
def none_for_1(value):
    return None if value == 1 else value


@register.simple_tag
def url_with_args(value: QueryDict, **kwargs):
    shit = {k: v for k, v in {**value.dict(), **kwargs}.items() if v}
    return '?' + urlencode(shit)
