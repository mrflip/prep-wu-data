#!/bin/env python
""" vcardin -- convert vCard .vcf data to hCard XHTML

Kid User's Guide
0.6.
Revision: 	131
Date: 	2005-03-09 15:26:45 -0500 (Wed, 09 Mar 2005)

.. kid_: http://lesscode.org/projects/kid/ moved> http://www.kid-templating.org/

"""

__version__ = '$Id: vcardin.py 433 2007-12-09 15:53:02Z mrflipco $'

# python std lib
import codecs, base64
# peer open source stuff
import kid # http://lesscode.org/projects/kid/
# local stuff
import icslex

class Usage(Exception):
    """
    Usage:

    python vcardin.py contact-template.kid c1.vcf c2.vcf >contacts.html
    """

    def __str__(self):
	return self.__doc__ + "\n"

def main(argv):
    
    try:
        kidfn = argv[1]
    except KeyError:
        raise Usage()

    template=kid.Template(file=kidfn)
    for txt in convert(template, concat(argv[2:])):
        sys.stdout.write(txt)

# property : (type, fields, min, max)
Properties = {'fn': ('text', None, 1, 1),
              'n': ('text', ('family-name',
                             'given-name',
                             'additional-name',
                             'honorific-prefix',
                             'honorific-suffix',), 1, 1),
              'nickname': ('text', None, 0, 1),
              'photo': ('mime', None, 0, 1),
              'bday': ('text', None, 0, 1), # datetime?
              'adr': ('text', ('post-office-box',
                               'extended-address',
                               'street-address',
                               'locality',
                               'region',
                               'postal-code',
                               'country-name'), 0, None),
              # 'type' and 'value' are lower level
              'label': ('text', None, 0, 1),
              'tel': ('text', None, 0, None),
              'email': ('text', None, 0, None),
              'mailer': ('text', None, 0, 1),
              'tz': ('text', None, 0, 1),
              'geo': ('float', ('latitude',
                                'longitude'), 0, 1),
              'title': ('text', None, 0, 1),
              'role': ('text', None, 0, 1),
              'logo': ('mime', None, 0, 1),
              'agent': ('vcard', None, 0, None),
              'org': ('text', ('organization-name',
                               'organization-unit'), 0, 1),
              'categories': ('text', (), 0, 1), #hmm... category or categories?
              'note': ('text', None, 0, 1),
              'rev': ('text', None, 0, 1), # datetime?
              'sort-string': ('text', None, 0, 1),
              'sound': ('mime', None, 0, 1),
              'uid': ('text', None, 0, 1),
              'url': ('text', None, 0, 1), #hmm... more than one URL?
              'class': ('text', None, 0, 1),
              'key': ('text', None, 0, 1),

              'prodid': ('text', None, 0, 1),
              'version': ('text', None, 0, 1),
              'source': ('text', None, 0, 1),
              'name': ('text', None, 0, 1),
              }

def convert(template, data):
    """generate XHTML from vcard data and kid template
    """
    lines = icslex.unbreak(data)
    template.contacts = contacts(Properties, lines)
    for txt in template.generate(output='xml', encoding='utf-8'):
        yield txt


def concat(files):
    """iterate over lines in a bunch of (utf-8) files

    @@this is in the python stdlib, surely
    """
    for fn in files:
        for line in codecs.open(fn, encoding='utf-8'):
            yield line


def contacts(schema, lines):
    while 1:
        try:
            delim, name, items = icslex.propertyitems(lines)
        except StopIteration:
            break

        if delim == 'begin': continue
        
        obj = {}
        for n, v in items:
            ty, fields, cmin, cmax = schema[n]

            if v.has_key('type'):
                v['type'] = v['type'].split(',')
            if fields:
                v.update(dict(lex_fields(v['_'], fields)))
            elif ty == 'text':
                v['text'] = icslex.unesc(v['_'])
            elif ty == 'mime':
                fix_bin(v)
            else:
                raise RuntimeError, 'type not implemented: %s' % ty

            if cmax is None:
                vlist = obj.get(n, None)
                if vlist is None:
                    vlist = obj[n] = []
                vlist.append(v)
            else:
                obj[n] = v

        yield obj


def lex_fields(txt, names, ty='text'):
    """parse the N parts and elaborate using hCard names

    >>> lex_fields('Doe;John;;;;', Properties['n'][1])
    [('family-name', 'Doe'), ('given-name', 'John')]
    """
    parts = txt.split(';') # @@ quoting details?
    if ty == 'text':
        parts = [icslex.unesc(v) for v in parts]
    return [(k, v) for k, v in zip(names, parts) if v]


def fix_bin(v):
    if v.get('value', None) == 'uri':
        v['uri'] = v['_'] #@@ unescaping?
    else:
        enc = v.get('encoding', None)
        if enc == 'b':
            b64 = v['_']
            v['uri'] = 'data:image/%s,%s' % (v['type'], b64)
            v['binary'] = base64.decodestring(b64)
        elif enc is None:
            plain = v['_']
            v['binary'] = plain
            v['uri'] = 'data:image/%s,%s' % (v['type'], plain)
        else:
            raise ValueError, "unknown encoding: %s" % enc

def _test():
    import doctest
    doctest.testmod()

if __name__ == '__main__':
    import sys

    if '--test' in sys.argv:
	_test()
    else:
	try:
	    main(sys.argv)
	except Usage, e:
	    sys.stderr.write(str(e))
	    sys.exit(2)

    
