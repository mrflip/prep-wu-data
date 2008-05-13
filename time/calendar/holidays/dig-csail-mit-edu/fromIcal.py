#!/usr/bin/python
"""fromIcal.py -- interpret iCalendar data as RDF

USAGE:
  python fromIcal.py  [options]  foo.ics > foo.rdf

  options:
    --base uri
    --noprotocol    Supress SEQUENCE and DTSTAMP
    --noalarm       Supress VALARMs
    --x             include X- properties

REFERENCES

 Internet Calendaring and Scheduling Core
 Object Specification (iCalendar)
 November 1998
 http://www.ietf.org/rfc/rfc2445.txt
 http://www.w3.org/2002/12/cal/rfc2445
 http://www.w3.org/2002/12/cal/rfc2445.html


  NOTE: We don't claim to implement the whole spec, nor to even have
   read all of it. We're taking a data-driven, test-driven approach
   to RFC2445 coverage/conformance. We start with a .ics file that we
   understand (because it came from a tool that acts as we expect in
   response to it or some such) and we implement the parts of the
   spec necessary to grok the data in that file. As we work on more
   test files, we cover (and carefully read) more parts of the spec.

 Building an RDF model: A quick look at iCalendar
 http://www.w3.org/2000/01/foo
 TimBL 2000/10/02


  Python Style Guide
  Author: Guido van Rossum
  http://www.python.org/doc/essays/styleguide.html

TODO
  - RDF API in place of SAX?
  - rename fromIcal.py?
  
LICENSE

RDF Calendar Workspace: http://www.w3.org/2002/12/cal/

Copyright 2002-2003 World Wide Web Consortium, (Massachusetts
Institute of Technology, European Research Consortium for
Informatics and Mathematics, Keio University). All Rights
Reserved. This work is distributed under the W3C(R) Software License
  http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.


"""

__version__ = "$Id: fromIcal.py 433 2007-12-09 15:53:02Z mrflipco $"


from warnings import warn
import codecs, quopri


import XMLWriter
from icslex import unbreak, parseLine, unesc, recurlex


def main():
    import sys
    
    sx = XMLWriter.T(codecs.getwriter('utf-8')(sys.stdout))

    base = None
    suppressed = ['X-']
    while len(sys.argv) > 1:
	if sys.argv[1] == '--base':
	    base = sys.argv[2]
	    del sys.argv[1:3]
	elif sys.argv[1] == '--noprotocol':
	    suppressed = suppressed + [ 'SEQUENCE', 'DTSTAMP']
	    del sys.argv[1:2]
	elif sys.argv[1] == '--x':
	    del suppressed[0]
	elif sys.argv[1] == '--noalarm':
	    suppressed = suppressed + [ 'Valarm']
	    del sys.argv[1:2]
	elif sys.argv[1] == '--notimezone':
	    suppressed = suppressed + [ 'Vtimezone']
	    del sys.argv[1:2]
	elif sys.argv[1] == '--help':
	    print __doc__
	    return
	else:
	    break

    interpret(sx, codecs.open(sys.argv[1], 'r', 'utf-8'), base, suppressed)

    
class Namespace:
    def __init__(self, nsURI, names=()):
        self._n = nsURI
        self._names = names


    def bindAttr(self, pfx, attrs):
        if pfx:
            attrs['xmlns:%s' % pfx] = self._n
        else:
            attrs['xmlns'] = self._n

    def __getattr__(self, lname):
        if lname in self._names:
            return self._n+lname
        else:
            raise AttributeError, lname

    def sym(self, lname):
	return self._n + lname
        
RDF = Namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#')
iCalendar = Namespace('http://www.w3.org/2002/12/cal/icaltzd#',
                      ('dateTime', ))
XMLSchema = Namespace('http://www.w3.org/2001/XMLSchema#',
                      ('dateTime', 'date', 'double', 'integer', 'duration'))


def interpret(sx, fp, base=None, suppressed =[]):
    lines = unbreak(fp)
    n, p, v = parseLine(lines.next())

    if v != 'VCALENDAR':
	raise SyntaxError('Expected CALENDAR but found: %s' % (v))
    calendars = []
    findComponents(lines, v, calendars)
    
    attrs = {}
    RDF.bindAttr('rdf', attrs)
    iCalendar.bindAttr('', attrs)
    if base:
        attrs['xml:base'] = base


    sx.startElement('rdf:RDF', attrs)

    doComponents(sx, calendars, iCalendarDefs, suppressed = suppressed)

    sx.endElement('rdf:RDF')


#########
#
# Property Declarations:
# ICALTOKEN -> ('rdfname', 'DEFAULT-TYPE', minCardinality, maxCardinality)
#
# In theory, these could be derived from the rfc2445-formal schema, but
# they're copied by hand, so far. Reading from rfc2445-formal rather
# than from rfc2445.txt ensures that we have the relevant information
# formalized in machine-readable form, but also provides careful
# review where a mechanized translation might mask some bugs.
#
# The default types are keyed in on-demand as we encounter
# the properties in test data. Those that we haven't tested
# produce a RuntimeError, telling us to add the default type
# (and a test case for it!).
#
# Mappings to rdfname and DEFAULT-TYPE could be flattened,
# but mappings to cardinalities depend on the containing component.
# Cardinalities aren't used yet. (oops; forgot YouArentGonnaNeedIt)
#
#
# We represent symbolic values as strings, i.e.
#     :transp "OPAQUE";
# where the calendar test suite currently uses URIs, i.e.
#     :transp :opaque;
# Relevant code is marked with @@symbol.
#
# See also "How should I implement controlled vocabularies?"
# in http://esw.w3.org/topic/PropertiesForNaming
#  as of 2003-04-18 16:10:57
#

tzprop = {
    "DTSTART": ('dtstart', 'DATE-TIME', 1, 1),
    "TZOFFSETTO": ('tzoffsetto', 'TEXT', 1, 1),
    "TZOFFSETFROM": ('tzoffsetfrom', 'TEXT', 1, 1),
    
    
    "COMMENT": ('comment', 'TEXT', 0, None),
    "RDATE": ('rdate', 'DATE-TIME', 0, None),
    "RRULE": ('rrule', 'RECUR', 0, None),
    'EXDATE': (u'exdate', 'DATE-TIME', None, None),
    'RECURRENCE-ID': (u'recurrenceId', 'DATE-TIME', None, None),
    "TZNAME": ('tzname', 'TEXT', 0, None),
    }

ValarmDefs = ('Valarm',
              {"ACTION": ('action', 'TEXT', 0, None), #@@symbol
               "ATTACH": ('attach', 'URI', 0, None),
               "ATTENDEE": ('attendee', 'CAL-ADDRESS', 0, None),
               "DESCRIPTION": ('description', 'TEXT', 0, 1),
               "DURATION": ('duration', 'DURATION', 0, None),
               "REPEAT": ('repeat', 0, None),
               "SUMMARY": ('summary', "TEXT", 0, None),
               "TRIGGER": ('trigger', "DURATION", 0, None),
               },
              {})

iCalendarDefs = {'VCALENDAR':
                 ('Vcalendar',
                  {'CALSCALE': ('calscale', 'TEXT', 0, 1),
                   'METHOD': ('method', 'TEXT', 0, 1),
                   'VERSION': ('version', 'TEXT', 1, 1),
                   'PRODID': ('prodid', 'TEXT', 1, 1),
                   },
                  
                  {'VTIMEZONE':
                   ('Vtimezone',
                    {"TZID": ('tzid', 'TEXT', 1, 1), #hmm... fragid?
                     "LAST-MODIFIED": ('lastModified', "DATE-TIME", 0, 1),
                     "TZURL": ('tzurl', 'URI', 0, 1),
                     },
                    {"STANDARD": ('standard', tzprop, {}),
                     "DAYLIGHT": ('daylight', tzprop, {})
                     }
                    ),
                   
                   'VEVENT':
                   ('Vevent',
                    {"ATTACH": ('attach', 'URI', 0, None),
                     "CATEGORIES": ('categories', "TEXT", 0, None), #@@list
                     "SUMMARY": ('summary', "TEXT", 0, None),
                     "DTEND": ('dtend', 'DATE-TIME', 0, None),
                     "DTSTART": ('dtstart', 'DATE-TIME', 0, None),
                     "DURATION": ('duration', 'DURATION', 0, None),
                     "TRANSP": ('transp', 'TEXT', 0, None), #@@symbol
                     "ATTENDEE": ('attendee', 'CAL-ADDRESS', 0, None),
                     "CONTACT": ('contact', 0, None),
                     "ORGANIZER": ('organizer', "CAL-ADDRESS", 0, None),
                     "RELATED-TO": ('relatedTo', 0, None),
        # notes on rfc2445#sec4.8.4.6 Uniform Resource Locator
        # 
        # This is very muddled modelling; url makes sense as
        # a value type, but not as a property name. It's a grab-bag
        # for concepts like foaf:homePage, dc:related (which
        # is another grab bag) etc.
                     "URL": ('url', 'URI', 0, None),
                     "UID": ('uid', "TEXT", 0, None),
                     "EXRULE": ('exrule', 0, None),
                     "CLASS": ('class', 'TEXT', 0, None), #@@symbol
                     "RDATE": ('rdate', 'DATE-TIME', 0, None),
                     "RRULE": ('rrule', 'RECUR', 0, None),
                     'EXDATE': (u'exdate', 'DATE-TIME', None, None),
                     'RECURRENCE-ID': (u'recurrenceId', 'DATE-TIME', None, None),
                     "TRIGGER": ('trigger', "DURATION", 0, None),
                     "CREATED": ('created', "DATE-TIME", 0, None),
                     "DTSTAMP": ('dtstamp', 'DATE-TIME', 1, 1),
                     "LAST-MODIFIED": ('lastModified', "DATE-TIME", 0, 1),
                     "SEQUENCE": ('sequence', "INTEGER", 0, None),
                     "REQUEST-STATUS": ('requestStatus', 0, None),
                     "COMMENT": ('comment', 'TEXT', 0, None),
                     "DESCRIPTION": ('description', "TEXT", 0, 1),
                     'GEO': ('geo', ('FLOAT',), None, None),
                     "LOCATION": ('location', 'TEXT', 0, None),
                     'PRIORITY': ('priority', 'INTEGER', None, None),
                     "RESOURCES": ('resources', 0, None),
                     "STATUS": ('status', 'TEXT', 0, 1),
                     },
                    {"VALARM": ValarmDefs }
                    ),
                   'VTODO':
                   (u'Vtodo',
                    {'ATTACH': (u'attach', 'URI', None, None),
                     'ATTENDEE': (u'attendee', 'CAL-ADDRESS', None, None),
                     'CATEGORIES'	: (u'categories', 'TEXT', None, None),
                     'CLASS': (u'class', 'TEXT', None, None),
                     'COMMENT': (u'comment', 'TEXT', None, None),
                     'COMPLETED': (u'completed', 'DATE-TIME', None, None),
                     'CONTACT': (u'contact', 'TEXT', None, None),
                     'CREATED': (u'created', 'DATE-TIME', None, None),
                     'DESCRIPTION': (u'description', 'TEXT', None, None),
                     'DTSTAMP': (u'dtstamp', 'DATE-TIME', None, None),
                     'DTSTART': (u'dtstart', 'DATE-TIME', None, None),
                     'DUE': (u'due', 'DATE-TIME', None, None),
                     'DURATION': (u'duration', 'DURATION', None, None),
                     'EXRULE': (u'exrule', 'RECUR', None, None),
                     'GEO': (u'geo', '@@', None, None),
                     'LAST-MODIFIED': (u'lastModified', 'DATE-TIME', None, None),
                     'LOCATION': (u'location', 'TEXT', None, None),
                     'ORGANIZER': (u'organizer', 'CAL-ADDRESS', None, None),
                     'PERCENT-COMPLETE': (u'percentComplete', 'INTEGER', None, None),
                     'PRIORITY': (u'priority', 'INTEGER', None, None),
                     'RDATE': (u'rdate', 'DATE-TIME', None, None),
                     'RELATED-TO': (u'relatedTo', 'TEXT', None, None),
                     'REQUEST-STATUS': (u'requestStatus', 'TEXT', None, None),
                     'RESOURCES': (u'resources', 'TEXT', None, None),
                     'RRULE': (u'rrule', 'RECUR', None, None),
                     'EXDATE': (u'exdate', 'DATE-TIME', None, None),
                     'RECURRENCE-ID': (u'recurrenceId', 'DATE-TIME', None, None),
                     'SEQUENCE': (u'sequence', 'INTEGER', None, None),
                     'STATUS': (u'status', 'TEXT', None, None),
                     'SUMMARY': (u'summary', 'TEXT', None, None),
                     'TRIGGER': (u'trigger', 'DURATION', None, None),
                     'UID': (u'uid', 'TEXT', None, None),
                     'URL': (u'url', 'URI', None, None)},
                    {"VALARM": ValarmDefs },
                    )
                   
                   #@@others
                   }
                  )
                 }


def doComponents(sx, components, compDecls, stripe=None, suppressed =[]):
    """interpret components

    stripe says whether we need a <component> element
    or a parseType="Resource" attribute to fix up the striping.
    or None, in which case we need to declare X- namespaces
    
    raises KeyError for unknown component name. @@test this
    """

    for name, props, subs in components:
        elt, propDecls, subDecls = compDecls[name]
	if elt in suppressed: 
	    continue
        attrs = {}
        if stripe == 'component':
            sx.startElement('component', {})
        elif stripe == 'Resource':
            attrs['rdf:parseType'] = stripe
        else:
            bindX(attrs, props, components)

        try:
            i = lookup(props, 'UID')
            if not('#' in i): i = "#" + i
            attrs['rdf:about'] = i
        except KeyError:
            try:
                tzid = lookup(props, 'TZID')
                attrs['rdf:about'] = timeZoneNameSpace(tzid) + 'tz'
            except KeyError:
                pass

        sx.startElement(elt, attrs)
        doProperties(sx, '', props, propDecls, suppressed = suppressed)

        if elt == 'Vtimezone':
            doComponents(sx, subs, subDecls, 'Resource', suppressed = suppressed)
        else:
            doComponents(sx, subs, subDecls, 'component', suppressed = suppressed)

        sx.endElement(elt)
        if stripe == 'component':
            sx.endElement('component')


def bindX(attrs, props, components):
    """ bind x: namespace per prodid

    hmm... use vendorid as prefix?
    """

    try:
        prodid = lookup(props, 'PRODID') #@@ call unesc to parse \,
    except KeyError:
        warn("RFC2445 requires a prodid. none found")
        return

    def findVendorids(results, components):
        for name, props, subs in components:
            for n, p, v in props:
                if n[:2] == "X-":
                    vendorid, lname = n[2:].split('-', 1)
                    results.append(vendorid.lower())
            findVendorids(results, subs)

    vendorids = []
    findVendorids(vendorids, components)
    puri = prodURI(prodid)
    for vid in vendorids:
        attrs['xmlns:x-' + vid] = puri

            

def lookup(props, k):
    for n, p, v in props:
        if n == k:
            return v
    raise KeyError, k

def prodURI(prodid):
    r"""turn prodid into a URI

    cf discussion starting with
    x-properties and namespaces
    posted by DanC at 2003-02-26 17:17 (+)
    http://rdfig.xmlhack.com/2003/02/26/2003-02-26.html#1046279854.884486
    and continuing thru
      RDF calendar agenda item C: prodid support to ical2rdf.pl
      posted by libby at 2003-07-09 14:59 (+)
      http://rdfig.xmlhack.com/2003/07/09/2003-07-09.html#1057762764.179078


    >>> prodURI("-//Apple Computer\, Inc//iCal 1.0//EN")
    'http://www.w3.org/2002/12/cal/prod/Apple_Comp_628d9d8459c556fa#'

    """

    import sha
    
    if prodid[:3] == "-//": prodid = prodid[3:]
    prodid = prodid.replace(' ', '_').replace("//", "_")
    digest = sha.new(prodid.lower()).hexdigest()
    return 'http://www.w3.org/2002/12/cal/prod/' + \
           prodid[:10] + '_' + digest[:16] + '#'





def doProperties(sx, pfx, props, schema, suppressed =[]):
    """write each property as XML
    
    raises KeyError for properties that are neither X-
    properties nor in the schema
    """
    
    for n, params, val in props:
	if n in suppressed:
	    continue

        if n[:2] == "X-":
            if 'X-' in suppressed: continue
            vendorid, lname = n[2:].split('-', 1)
            id = 'x-' + vendorid.lower() + ':' + camelCase(lname)
            vtype, minc, maxc = 'TEXT', 0, None
        else:
	    try:
                id, vtype, minc, maxc = schema[n]
            except ValueError:
                raise RuntimeError, "missing default type: %s -> %s" %\
                      (n, schema[n])


        elt = '%s%s' % (pfx, id)

        for pn, pv in params:
            if pn == 'VALUE':
                vtype = pv.upper()
        if vtype == 'TEXT':
            doText(sx, elt, params, val)
        elif vtype == 'INTEGER':
            doInteger(sx, elt, params, val)
        elif vtype == 'DURATION':
            doDuration(sx, elt, params, val)
        elif vtype == 'DATE-TIME':
            doDateTime(sx, elt, params, val)
        elif vtype == 'DATE':
            doDate(sx, elt, params, val)
        elif vtype == 'RECUR':
            doRecur(sx, elt, params, val)
        elif vtype == 'CAL-ADDRESS':
            doCalAddress(sx, elt, params, val)
        elif vtype == 'URI':
            doURI(sx, elt, params, val)
        elif vtype == ('FLOAT',):
            doListOfFLOAT(sx, elt, params, val)
        else:
            warn("@@value type %s not implemented (%s: %s)" % (vtype, n, val))

def doInteger(sx, elt, params, val):
    sx.startElement(elt, {'rdf:datatype': XMLSchema.integer})
    sx.characters(val, 0, len(val))
    for pn, pv in params:
        if pn=='VALUE': pass
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)
    sx.endElement(elt)

def doURI(sx, elt, params, val):
    sx.startElement(elt, {'rdf:resource': val})
    for pn, pv in params:
        if pn=='VALUE': pass
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)
    sx.endElement(elt)

def doText(sx, elt, params, val):
    attrs = {}

    val = unesc(val)   # @@ or only if not QUOTED-PRINTABLE ?

    for pn, pv in params:
        if pn=='VALUE': pass
	elif (pn, pv) == ('ENCODING', 'QUOTED-PRINTABLE'):
	    val = quopri.decodestring(val)
	elif pn == "LANGUAGE":
	    attrs[ 'xml:lang'] = pv
        else:
            warn("unexpected param %s=%s on elt '%s'" % (pn, pv, elt))

    sx.startElement(elt, attrs)
    sx.characters(val, 0, len(val))
    sx.endElement(elt)


# Hmm... we can't use dt:dateTime nor dt:duration as the property
# here, because datatype properties are inverse functional, but
# iCalendar DATE-TIME values have other properties, i.e. tzid.
#
# In a way, it's a good thing anyway, since using datatype properties
# would take us out of OWL DL.

def doDateTime(sx, elt, params, val):
    val = datePunc(val)

    tzid = None
    
    for pn, pv in params:
        if pn == 'VALUE': pass # delete this in doParams?
        elif pn == 'TZID':
            tzid = pv
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)

    if val.endswith('Z'):
        sx.startElement(elt, {'rdf:datatype': XMLSchema.dateTime})
        sx.characters(val, 0, len(val))
        sx.endElement(elt)
    elif tzid:
        sx.startElement(elt, {'rdf:datatype': timeZoneNameSpace(tzid)+'tz'})
        sx.characters(val, 0, len(val))
        sx.endElement(elt)
    else:
        sx.startElement(elt, {'rdf:datatype': iCalendar.dateTime})
        sx.characters(val, 0, len(val))
        sx.endElement(elt)



OlsonPfxs=('/softwarestudio.org/Olson_20011030_5/',
           '/softwarestudio.org/Olson_20010831_3/',
           '/softwarestudio.org/Olson_20011030_4/',
           '/softwarestudio.org/Olson_20020614_6/',
           '/softwarestudio.org/Olson_20011030_2/')
TzdPfx='http://www.w3.org/2002/12/cal/tzd/'

def timeZoneNameSpace(tzid):
    """map tzid into URI space rooted at TzdPfx

    rfc2445#sec4.8.3.1 says:
    "The presence of the SOLIDUS character (US-ASCII
    decimal 47) as a prefix, indicates that this TZID represents an
    unique ID in a globally defined time zone registry (when such
    registry is defined)."

    >>> timeZoneNameSpace('/softwarestudio.org/Olson_20011030_5/Europe/London')
    'http://www.w3.org/2002/12/cal/tzd/Europe/London#'

    If an unknown registry is uses...
    
    >>> timeZoneNameSpace('/foo')
    Traceback (most recent call last):
      raise ValueError, "unknown global tzid:" + tzid
    ValueError: unknown global tzid:/foo


    We do some namespace squatting: in theory,
    the name 'Europe/London' could be used as a local reference
    for Chicago time. But in practice, this works:
    
    >>> timeZoneNameSpace('Europe/London')
    'http://www.w3.org/2002/12/cal/tzd/Europe/London#'

    A bit more squatting:
    >>> timeZoneNameSpace('US/Eastern')
    'http://www.w3.org/2002/12/cal/tzd/America/New_York#'

    
    @@raises RuntimeError for unrecognized local refs.
    
    """
    
    if tzid.startswith('/'):
        for pfx in OlsonPfxs:
            if tzid.startswith(pfx):
                tzns = TzdPfx + tzid[len(pfx):] + '#'
                break
        else:
            raise ValueError, "unknown global tzid:" + tzid
    else:
        tzid = {'US/Eastern': 'America/New_York',
                'US/Central': 'America/Chicago',
                # mountain? denver?
                'US/Pacific': 'America/Los_Angeles',
                }.get(tzid, tzid)
        
        for area in ('Africa', 'Antarctica', 'Asia', 'Australia',
                     'Europe', 'Pacific', 'America', 'Arctic', 'Atlantic',
                     'Indian'):
            if tzid.startswith(area + '/'):
                tzns = TzdPfx + tzid + '#'
                break
        else:
            raise RuntimeError, "unsupported local timezone: " + tzid
    return tzns


def doDate(sx, elt, params, val):
    sx.startElement(elt, {'rdf:datatype': XMLSchema.date})

    val = "%s-%s-%s" % (val[:4], val[4:6], val[6:8])
    sx.characters(val, 0, len(val))

    for pn, pv in params:
        if pn == 'VALUE': pass # delete this in doParams?
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)
    sx.endElement(elt)

def doCalAddress(sx, elt, params, val):
    sx.startElement(elt, {'rdf:parseType': "Resource"})

    val = val.replace("MAILTO:", 'mailto:') # rfc2445#sec4.3.3 weirdness
    # hmm... use or mention of the address?
    sx.startElement('calAddress', {'rdf:resource': val})
    sx.endElement('calAddress')

    for pn, pv in params:
        if pn == 'VALUE': pass # delete this in doParams?
        elif pn == 'CN':
            sx.startElement('cn', {}) #@@ add to ical schema
            sx.characters(pv, 0, len(pv))
            sx.endElement('cn')
        elif pn == 'DIR':
            sx.startElement('dir', {'rdf:resource': pv})
            sx.endElement('cn')
        elif pn in ('CUTYPE', 'ROLE', 'RSVP', 'PARTSTAT', 'LANGUAGE'):
            pn = pn.lower() # lower is sufficient to camelCase
            pv = pv.upper() # @@symbol
            sx.startElement(pn, {})
            sx.characters(pv, 0, len(pv))
            sx.endElement(pn)
	elif pn == 'X-UID':
	    pn = pn.lower()    # @@@@ should be namespaced from the client software mfr
            sx.startElement(pn, {})
            sx.characters(pv, 0, len(pv))
            sx.endElement(pn)
	    
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)
    sx.endElement(elt)

def doRecur(sx, elt, params, val):
    sx.startElement(elt, {'rdf:parseType': "Resource"})

    for n, v in recurlex(val, downcase=False).iteritems():
        sx.startElement(n, type(v) is type(1) and \
                        {'rdf:datatype': XMLSchema.integer} or {})
        sx.characters(str(v), 0, len(str(v)))
        sx.endElement(n)
    for pn, pv in params:
        if pn == 'VALUE': pass # delete this in doParams?
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)

    sx.endElement(elt)

def doDuration(sx, elt, params, val):
    """duration is an odd beast in iCalendar. There is a duration
    property as well as a duration value type. We'll use cal:duration
    for the property.

    The DURATION value type is actually more than just a
    XMLSchema.duration; it also has a RELATED parameter.
    So for
      TRIGGER;VALUE=DURATION;RELATED=START:-PT15M
    we'll write
      { ?E cal:trigger [ rdf:value "-PT15M"^^xsdt:duration;
                         cal:related "START"] }
    """
    sx.startElement(elt, {'rdf:parseType': "Resource"})
    sx.startElement('rdf:value', {'rdf:datatype': XMLSchema.duration})
    sx.characters(val, 0, len(val))
    sx.endElement('duration')
    for pn, pv in params:
        if pn == 'VALUE': pass # delete this in doParams?
        elif pn == 'RELATED':
            pv = pv.upper() # rfc2445#sec2 names
            sx.startElement('related', {})
            sx.characters(pv, 0, len(pv))
            sx.endElement('related')
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)
    sx.endElement(elt)


# We considered generalizing this to lists of
# other sorts of values but declined on the
# YouArentGonnaNeedIt principle.
def doListOfFLOAT(sx, elt, params, val):
    x, y = val.split(';')

    for pn, pv in params:
        if pn=='VALUE': pass
        else:
            raise ValueError, "unexpected param %s=%s" % (pn, pv)

    #ugh... can't use parseType="Collection" with literal values
    #http://www.w3.org/2000/03/rdf-tracking/#rdfxml-literals-in-collections
    sx.startElement(elt, {'rdf:parseType': "Resource"})

    sx.startElement('rdf:first', {'rdf:datatype': XMLSchema.double})
    sx.characters(x, 0, len(x))
    sx.endElement('rdf:first')

    sx.startElement('rdf:rest', {'rdf:parseType': "Resource"})

    sx.startElement('rdf:first', {'rdf:datatype': XMLSchema.double})
    sx.characters(y, 0, len(y))
    sx.endElement('rdf:first')

    sx.startElement('rdf:rest',
                    {'rdf:resource':
                     'http://www.w3.org/1999/02/22-rdf-syntax-ns#nil'})
    sx.endElement('rdf:rest')
    sx.endElement('rdf:rest')

    sx.endElement(elt)


def datePunc(val):
    """convert RFC2445 date to ISO/W3C/XML date form

    >>> datePunc('19701025T020000')
    '1970-10-25T02:00:00'
    >>> datePunc('20020630T230353Z')
    '2002-06-30T23:03:53Z'
    """
    return "%s-%s-%sT%s:%s:%s%s" % (val[:4], val[4:6], val[6:8],
                                    val[9:11], val[11:13], val[13:15],
                                    val[15:])


def camelCase(n, initialCap=0):
    """
    >>> camelCase("VEVENT", 1)
    'Vevent'
    
    >>> camelCase("LAST-MODIFIED")
    'lastModified'

    >>> camelCase("LOCATION")
    'location'
    """
    
    words = map(lambda w: w.lower(), n.split('-'))

    def ucfirst(w):
        return w[0].upper() + w[1:]
    
    if initialCap:
        return ''.join(map(ucfirst, words))
    else:
        return words[0] + ''.join(map(ucfirst, words[1:]))


def findComponents(lines, container, components=[]):
    """return a list of (name, props, subcomponents) and remaining lines

    # @@TODO: make this a generator

    """

    props = []
    subs = []

    while 1:
        try:
            n, p, v = parseLine(lines.next(), downcase=False)
        except StopIteration:
            break
        #print "finding...", n, p, v

        #print >>sys.stderr, "began", container, n, p, v
        if n == 'END':
            # @@hmm... found an extra space after END:DAYLIGHT
            # in test/20030410querymtg.ics
            # where did that come from? allow it, or fix test data?
            v = v.rstrip().upper()
            if v != container:
                raise ValueError, 'expected "%s" but found "%s"' % \
                      (container, v)
            components.append((container, props, subs))
            return
        elif n == 'BEGIN':
            findComponents(lines, v, subs)
        else:
            props.append((n, p, v))
            
    
def _test():
    import sys
    from pprint import pprint
    import doctest, fromIcal
    doctest.testmod(fromIcal)

    lines = unbreak(open(sys.argv[1]))
    n, p, v = parseLine(lines.next())
    c = []
    findComponents(lines, v, c)
    pprint(c)
    #unittest.main()

if __name__ == '__main__':
    import sys
    if sys.argv[1] == '--test':
        del sys.argv[1]
        _test()
    else:
        main()

# $Log: fromIcal.py,v $
# Revision 2.33  2007/02/20 14:58:45  timbl
# explain what we found if not CALENDAR
#
# Revision 2.32  2006/04/21 16:46:46  connolly
# demote unexpected param on text to warning, to deal with x2v's charset hack
#
# Revision 2.31  2006/04/11 20:29:00  connolly
# finished factoring out icslex stuff: unbreak, parseLine
# findComponents is now more straightforwardly recursive
#
# Revision 2.30  2006/04/09 06:02:39  connolly
# changeset:   7:5f8c551b2de38fb115789dfe7cbca0288a978f61
# tag:         tip
# user:        Dan Connolly <connolly@w3.org>
# date:        Sun Apr  9 01:01:32 2006 -0500
# files:       icslex.py
# description:
# add bymonthday to recurlex
#
#
# changeset:   6:32c567b22753c64f71c8de298adb87bad91ef567
# user:        Dan Connolly <connolly@w3.org>
# date:        Sun Apr  9 00:54:59 2006 -0500
# files:       icsxml.py
# description:
# use utf-8 to read files; kludge a couple more fields that the template assumes
#
#
# changeset:   5:12370cd5ad97cd5cea04e7ed4d5f6b55c0ac39ff
# user:        Dan Connolly <connolly@w3.org>
# date:        Sun Apr  9 00:54:13 2006 -0500
# files:       icslex.py
# description:
# make interval explict; use utf-8 to read files
#
#
# changeset:   4:0f319182ea4d6ee8a8b7f2ef042683323b75658d
# user:        Dan Connolly <connolly@w3.org>
# date:        Sun Apr  9 00:37:07 2006 -0500
# files:       icsxml.py
# description:
# works in one case, with a couple kludges
#
#
# changeset:   3:3e542292c8040d0dab310748ef07ffbce0a15b4a
# user:        Dan Connolly <connolly@w3.org>
# date:        Sun Apr  9 00:36:43 2006 -0500
# files:       icslex.py
# description:
# date, recur lex details
#
#
# changeset:   2:c2881393d0156b9263d760e98953ece6ba7591a6
# user:        Dan Connolly <connolly@w3.org>
# date:        Sun Apr  9 00:01:33 2006 -0500
# files:       icslex.py
# description:
# - parsing collections of properties as a dict/JSON object works
# - names are downcased by default
# - formatted docs per rst/epydoc
#
#
# changeset:   1:ecc1ad118fc61abb55e9634d15921483134f3328
# user:        Dan Connolly <connolly@w3.org>
# date:        Sat Apr  8 22:06:28 2006 -0500
# files:       icslex.py
# description:
# unbreak works
#
#
# changeset:   0:ec6eb270779b1ae046b9dd04be92034375392722
# user:        Dan Connolly <connolly@w3.org>
# date:        Sat Apr  8 21:50:45 2006 -0500
# files:       icslex.py
# description:
# parseLine tests pass
#
# Revision 2.29  2005/11/09 23:10:48  connolly
# - changed the way duration values are modelled
#     The iCalendar DURATION value type is actually more than just a
#     XMLSchema.duration; it also has a RELATED parameter.
#     So for
#       TRIGGER;VALUE=DURATION;RELATED=START:-PT15M
#     we'll write
#       { ?E cal:trigger [ rdf:value "-PT15M"^^xsdt:duration;
#                          cal:related "START"] }
#
# - fixed test data to have rdf:datatype on integer
#   values, to match the schema (which matches the RFC)
#
# - fixed schema to show DATE-TIME properties (dtstart, ...)
#   as DatatypeProperties
#   (there are little/no tests for PERIOD; beware)
#
# - scraped more details about property parameters (e.g. partstat, cn,
#   cutype, ...) and rrule parts (freq, interval, ...) from the RFC so
#   that they show up as links in the hypertext version and as RDF
#   properties in the schema.  likewise timezone components (standard,
#   daylight)
#  - side effect: added some whitespace in rfc2445.html
#
# - demoted x- properties
#  - removed x- properties from .rdf versions of test data
#    this allows the round-trip tests to pass
#  - fromIcal.py doesn't output them unless you give the --x option
#
# - added Makefile support for consistency checking with pellet
#
# - demoted blank line diagnostic in fromIcal.py to a comment
#
# - silenced some left-over debug diagnostics in slurpIcalSpec.py
#
# - fixed test/test-created.rdf; added it to fromIcalTest.py list
#
# Revision 2.28  2005/09/08 00:43:49  connolly
# avoid double hashes in ID
#
# Revision 2.27  2005/04/22 14:16:56  connolly
# fix problems found when converting all the timezone files
# in evolution-data-server_1.0.4-1_i386.deb:
# - handle RDATE
# - handle multiple OlsonPfxs
#
# Revision 2.26  2005/04/04 21:17:14  connolly
# fix initialization of iCalendar namespace
#
# Revision 2.25  2005/03/30 15:35:21  connolly
# new namespace for timezones-as-datatypes design: icaltzd
#
# Revision 2.24  2005/02/26 03:20:47  connolly
# fromIcal.py
# - revert the uid: trick; back to uids as fragids
# - timezones as datatypes in dates, dateTimes
# - Valarm supported in Vtodo as well as Vevent
#   (@@need test smaller than MozMulipleVcalendars.ics)
# - re-indented Vtodo decls while I was at it
# - case-fold END:xyz
#
# fromIcalTest.py
# - base in http space
# - new tag-bug case
#
# test/*.rdf
# - base in http space
# - timezones as datatypes
#
# test/cal-regression.n3
# - moved tests that don't use X- first
# - got rid of initRDF
#
# test/cal-retest.py
# - replace ical2rdf.pl with fromIcal.py
# - base in http space
#
# test/cal-spec-examples.n3 new
#
# test/graphCompare.n3 oops; extra debug crud
#
# Revision 2.23  2005/02/10 21:39:00  timbl
# COUNT, LANGUAGE, X-UID, QUOTED-PRINTABLE under DanC's supervision
#
# Revision 2.22  2005/02/02 21:54:45  timbl
# added --noalarm option - kindofa hack - take 2
#
# Revision 2.21  2005/02/02 21:51:46  timbl
# added --noalarm option - kindofa hack
#
# Revision 2.20  2005/02/02 21:39:20  timbl
# sync
#
# Revision 2.19  2005/02/01 15:29:43  timbl
# hack to CREATED to add default type DATE-TIME.
#
# Revision 2.18  2005/02/01 15:26:53  timbl
# pre hack to CREATED  default type.
#
# Revision 2.17  2005/01/28 04:07:49  timbl
# Event URIs now absolute. Added --noprotocol and --help options
#
# Revision 2.16  2004/09/30 14:16:01  connolly
# parseLine was buggy in the case of ; in values
#
# Revision 2.15  2004/04/14 21:31:26  connolly
# added --base support so we can test with fragids
#
# Revision 2.14  2004/04/14 21:12:13  connolly
#
# - revamped doDateTime: use datatypes for dateTime values
#   - added __getattr__ to Namespace class
# - make well-known tzids into URIs in 2002/12/cal space
# - make UID into fragid
# - make local tzid into fragid
#
# Revision 2.13  2004/04/08 14:09:11  connolly
# priority on VEVENT fixed
#
# Revision 2.12  2004/04/07 18:27:17  connolly
# use real datatypes for list of floats, i.e. geo
#
# Revision 2.11  2004/04/07 18:10:22  connolly
# convert list of float, as in GEO
#
# Revision 2.10  2004/03/25 04:00:59  connolly
# allow recurrenceId wherever rrule can go
# handle WKST in recur values
#
# Revision 2.9  2004/03/25 03:45:09  connolly
# handle UNTIL in rrule
# added EXDATE to compDecls wherever RRULE occurs
#
# Revision 2.7  2004/03/23 14:59:28  connolly
# allow missing PRODID
#
# Revision 2.6  2004/03/10 21:59:31  connolly
# calendar schema is now generated from the RFC
#
# Revision 2.5  2004/02/29 14:52:11  connolly
# todo support in fromIcal; value type label in schema
#
# Revision 2.4  2004/02/12 07:17:05  connolly
# - handle URI value type
# - a few more default value type declarations
#
# Revision 2.3  2004/02/12 06:30:48  connolly
# - doText unescapes text values per rfc2445#sec4.3.11
# - LAST-MODIFIED applies to VEVENT (fixed typo in RFC)
# - default type added for COMMENT
# - disabled UID->fragid conversion cuz it interferes with graph comparison
# - handle DIR parameter on CAL-ADDRESS value type
#
# Revision 2.2  2004/02/11 22:04:10  connolly
# slightly nicer XML writer
#
# Revision 2.1  2004/02/11 16:40:23  connolly
# finish renaming icalWebize.py to fromIcal.py
#
# Revision 2.0  2004/02/11 16:37:48  connolly
# copied from icalWebize.py
#
# Revision 1.11  2004/02/09 23:09:11  connolly
# - more refined X- property handling
# - generate fragids for uid, TZID
# - fixed utf-8 reading (thx MK for move test data!)
# - noted RDF API, name change TODOs per discussion with timbl
# - allow blank lines, space after names, (warn about possible confict with RFC)
# - pass over VALUE parameter in doText
#
# Revision 1.10  2004/02/08 19:14:39  connolly
# handles all of cal01.ics, though not quite the same way
# that ical2rdf.pl does
# - elaborated comment about declarations and rfc2445-formal
# - elaborated @@symbol comment
# - fixed tzoffsetfrom decl bug
# - handle X- properties
# - handle DATE value type
# - changed calAddress to use, rather than mention, ala ical2rdf.pl
# - handle (and test) Z on dateTimes
# - more uniform handling of case insensitivity (still not tested)
#
# Revision 1.9  2004/02/08 05:17:56  connolly
# working except X- props
# symbols are still text; not (yet?) interpreted as URIs
# treating Valarm as a class; leading toward changing it this way
#
# Revision 1.8  2004/02/08 04:28:43  connolly
# removed i: prefix
# enough property declarations with value types for cal01.ics
# added <component> elements and parseType to fix striping
# factored out text property code
#
# Revision 1.7  2004/02/08 00:10:00  connolly
# data-driven processing of components
#
# Revision 1.6  2004/02/07 06:28:35  connolly
# note a bug with unescaping TEXT values
#
# Revision 1.5  2004/02/07 03:40:17  connolly
# note intention to use generators
# rearrange module docstring
#
# Revision 1.4  2004/02/06 07:41:41  connolly
# syntax bug in one of the "not implemented" warnings
#
# Revision 1.3  2004/02/06 07:13:24  connolly
# started support for VEVENT
#   - TODO: reformat dates
#   - non-text properties; e.g. organizer
# moved main() before Namespace class
#
# Revision 1.2  2004/02/06 06:56:38  connolly
# lines are arranged into components
# calendar object and its properties are written as RDF
#
# Revision 1.1  2004/02/06 05:22:11  connolly
# parses lines into name, params, value
#

