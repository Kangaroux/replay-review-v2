import re

from django.core import validators
from django.core.validators import RegexValidator
from django.utils.translation import ugettext_lazy as _

MIN_USERNAME_LENGTH = 4
MAX_USERNAME_LENGTH = 20

username_has_letter = RegexValidator(
  regex=r'[a-zA-Z]',
  message = _("Username must contain at least 1 letter.")
)

username = [username_has_letter]