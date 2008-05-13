"""icslex -- lexical details of iCalendar.

References
----------

 * *Internet Calendaring and Scheduling Core Object Specification (iCalendar)*
   November 1998 RFC2445_

.. _RFC2445: http://www.w3.org/2002/12/cal/rfc2445

"""

__docformat__ = "restructuredtext en"

def main(args):
    """Do a lexical scan over icalendar files; print the results.
    """
    from pprint import pprint
    import codecs

    level = 0
    for fn in args:
	fp = codecs.open(fn, encoding='utf-8')
	lines = unbreak(fp)
	while 1:
	    obj = {}
	    try:
		delim, name = properties(lines, obj)
	    except StopIteration:
		break

	    if obj: pprint(obj)
	    if delim == 'end': level -= 1
	    print '..' * level, delim, name
	    if delim == 'begin': level += 1


def properties(lines, obj):
    """populate a JSON_ style object from iCalendar properties.
    Stop at the next begin/end line.

    Duplicate properties are clobbered. See propertyitems
    for an interface that doesn't clobber.
    
    :param lines: an interator over input lines
        that have already been thru unbreak()

    :param obj: a dict to update

    :return: name

    .. _JSON: http://www.json.org/
    """

    delim, n, items = propertyitems(lines)
    obj.update(dict(items))
    return delim, n


def propertyitems(lines):
    """return a list of iCalendar properties.
    Stop at the next begin/end line.

    :param lines: an interator over input lines
        that have already been thru unbreak()

    :return: n, l where l is a list of (property, {facet: value...}) items
		  and n is the property name

    .. _JSON: http://www.json.org/
    """
    items = []
    n, p, v = parseLine(lines.next())

    while 1:
	n, p, v = parseLine(lines.next())
	if n in ('begin', 'end'):
	    return n, v, items
        pd = dict(p)
        cs = pd.get('charset', None)
        if cs == 'UTF-8':
            del pd['charset']
        elif cs is not None:
            raise ValueError, 'charset not supported: %s' % ((n, p, v),)
        v = {'_': v}
        v.update(pd)
        items.append((n, v))

def parseLine(ln, downcase=True):
    """break a content line into name, params, value

    :param downcase: whether to normalize names of properties and
        parameters to lower case

    >>> parseLine("RDATE;VALUE=DATE:19970304,19970504,19970704,19970904")
    ('rdate', [('value', 'DATE')], '19970304,19970504,19970704,19970904')

    >>> parseLine("RDATE;VALUE=DATE:19970304,19970504,19970704,19970904", 0)
    ('RDATE', [('VALUE', 'DATE')], '19970304,19970504,19970704,19970904')

    >>> parseLine('DESCRIPTION;ALTREP="http://www.wiz.org":The Fall 98 Wild Wizards Conference - - Las Vegas, NV, USA', 0)
    ('DESCRIPTION', [('ALTREP', 'http://www.wiz.org')], 'The Fall 98 Wild Wizards Conference - - Las Vegas, NV, USA')

    >>> parseLine('URL;VALUE=URI:https://www.virtual.example/new/reservations.html;jsessionid=A2j3D8E6b112FjARUGSFSHBqBe7OafARYkuR0F7lbCV0HNKa5kRh!-346797512!-1748917503!7001!8001?JSESSIONID=A2j3D8E6b112FjARUGSFSHBqBe7OafARYkuR0F7lbCV0HNKa5kRh!-346797512!-1748917503!7001!8001&pnr=Clksdjf', 0)
    ('URL', [('VALUE', 'URI')], 'https://www.virtual.example/new/reservations.html;jsessionid=A2j3D8E6b112FjARUGSFSHBqBe7OafARYkuR0F7lbCV0HNKa5kRh!-346797512!-1748917503!7001!8001?JSESSIONID=A2j3D8E6b112FjARUGSFSHBqBe7OafARYkuR0F7lbCV0HNKa5kRh!-346797512!-1748917503!7001!8001&pnr=Clksdjf')

    >>> parseLine('PHOTO;BASE64:')
    ('photo', [('base64', None)], '')

    """

    params = []
    semi = ln.find(';')
    colon = ln.find(':')

    if semi >= 0 and semi < colon:
        name = ln[:semi]
        while semi < colon:
            eq = ln.find('=', semi)
	    if eq < 0 or eq > colon:
		pval = None
		eq = semi
                semi = ln.find(';', eq+1)
                colon = ln.find(':', eq+1)
                if semi < 0 or semi > colon: semi = colon
		pname = ln[eq+1:semi]
	    else:
		pname = ln[semi+1:eq]
		if ln[eq+1] == '"':
		    strend = ln.find('"', eq+2)
		    pval = ln[eq+2:strend]
		    semi = ln.find(';', strend+1)
		    colon = ln.find(':', strend+1)
		else:
		    semi = ln.find(';', eq+1)
		    colon = ln.find(':', eq+1)
		    if semi < 0 or semi > colon: semi = colon
		    pval = ln[eq+1:semi]
	    if downcase: pname = pname.lower()
            params.append((pname, pval))
            if semi < 0: break
    else:
        name = ln[:colon]
    if downcase: name = name.lower()
    value = ln[colon+1:]
    return name, params, value

def unesc(val):
    r""" undo escaping ala rfc2445#sec4.3.11

    >>> unesc("abc\\ndef")
    'abc\ndef'
    
    >>> unesc("abc\\\\def")
    'abc\\def'
    
    """
    
    i = 0
    ret = ''
    while i < len(val):
        j = val.find('\\', i)
        if j < 0:
            ret += val[i:]
            break
        ret += val[i:j]
        c = val[j+1]
        if c == 'n' or c == 'N': c = LF
        ret += c
        i = j + 2
    return ret


def asDate(item):
    """punctuate item as per ISO8601 and W3C XML Schema datatypes

    >>> asDate("20041225")
    '2004-12-25'
    >>> asDate("20041202T170000Z")
    '2004-12-02T17:00:00Z'
    >>> asDate("20020513T163000")
    '2002-05-13T16:30:00'
    """
    if len(item) > 14:
	return "%s-%s-%s:%s:%s" % (item[:4], item[4:6], item[6:11],
				   item[11:13] ,item[13:])
    elif len(item) == 8:
	return "%s-%s-%s" % (item[:4], item[4:6], item[6:8])
    else:
	raise ValueError, item

#############
# rfc2445#sec4.1 Content Lines
#
CR = chr(13)
LF = chr(10)
CRLF = CR + LF
SPACE = chr(32)
TAB = chr(9)

def unbreak(lines):
    """turn a generator of raw lines into a generator of unbroken lines
    """
    ln = ''
    while 1:
	try:
	    s = lines.next().rstrip(CRLF)
	except StopIteration:
	    break
	if not s:
		# hmm... RFC2445 seems to prohibit blank lines, but we skip them.
	    continue
	if s[0] in (SPACE, TAB):
	    ln += s[1:]
	else:
	    if ln: yield ln
	    ln = s

    if ln: yield ln

def recurlex(val, downcase=True):
    obj = {}
    for n_v in val.split(';'):
        n, v = n_v.split('=')
	n = n.lower()
        if n in ('freq', 'byday', 'bymonth', 'wkst'):
            if downcase: v = v.lower()
	    obj[n] = v
	elif n == 'until':
	    obj[n] = asDate(v)
        # hmm... rfc2445 isn't explicit about datatype for count, interval
	elif n in ('interval', 'count', 'bymonthday'):
	    obj[n] = int(v)
        else:
            raise ValueError, "unexpected rrule arg %s=%s" % (n, v)

    # fill in defaults
    if not obj.has_key('interval'):
	obj['interval'] = 1

    return obj

def _test():
    import doctest
    doctest.testmod()

if __name__ == '__main__':
    import sys

    if '--test' in sys.argv:
	_test()
    else:
	main(sys.argv[1:])
