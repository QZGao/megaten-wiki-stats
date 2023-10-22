from __future__ import absolute_import, division, unicode_literals

from pywikibot import family
from pywikibot.tools import deprecated

class Family(family.Family):

    name = 'megaten'
    langs = {
        'en': 'megamitensei.fandom.com',
        'zh': 'megamitensei.fandom.com',
    }

    def scriptpath(self, code):
        return {
            'en': '',
            'zh': '/zh',
        }[code]

    @deprecated('APISite.version()')
    def version(self, code):
        return '1.31.2'

    def protocol(self, code):														 
        return 'HTTPS'