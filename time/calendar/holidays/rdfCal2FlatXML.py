#!/public/bin/python
from lxml import etree 		
from lxml import objectify
from urllib2 import urlopen
import fnmatch, os, os.path
import re
E = objectify.E

# Namespaces
nslist = {'rdf' :"http://www.w3.org/1999/02/22-rdf-syntax-ns#",
	  'hcal':"http://www.w3.org/2002/12/cal/icaltzd#"}

# sugar for getting an event field
def getsubtag(ev, tag):
    return ''.join(ev.xpath('.//hcal:'+tag+'/text()', nslist))
    

# Get files
caldir = '/home/flip/rawd/time/calendar/holidays/mozilla-xml'
# Also, track each event tag we've seen
alltags = {}
for filename in [os.path.join(caldir,filename)
                 for filename in os.listdir(caldir)
                 if  os.path.isfile(os.path.join(caldir,filename)) and
                 fnmatch.fnmatch(filename, '*.xml')][0:11]:
    (country,lang)=re.search(r'holidays-([^\-]*)(-.*)?\.xml',filename).group(1,2)
    cal  = etree.ElementTree(file=open(filename))  # or sub in urlopen(uri)

    # Start the output tree
    holidaytree = E.holidays (
        E.holidaygroup(
        ))

    # Sort the holidays by name
    evs = cal.xpath('//hcal:Vevent',nslist)
    evs.sort(
        key=lambda a: getsubtag(a,'summary').lower()
        )

    # The following event tags have been observed in the wild:
    # categories
    # summary   	description	url
    # dtend		dtstart
    # rrule
    # 
    # component		sequence ?
    # 
    # 
    #Ignorable:
    # status	transp  		class		priority	recurrenceId	uid				
    #Creation
    # lastModified	created  	dtstamp 	
    # categories      class   component       created description     dtend   dtstamp dtstart lastModified    priority        recurrenceId    rrule   sequence        status  summary transp  uid     url

    # make a holiday element for each event
    for (idx,ev) in enumerate(evs):
        hol = etree.Element("holiday", country=country)
        if lang: hol.attrib['lang'] = lang 
        hol.attrib.update(dict([
            (evtag[0], getsubtag(ev, evtag[1]))
            for evtag in ({
                           'start':'dtstart','end':'dtend',
                           'name':'summary', 'cat':'categories',
                           'freq':'rrule/hcal:freq',
                           'byday':'rrule/hcal:byday',
                           'desc':'description',
                           }.items())]))
        alltags.update(dict([(el.tag,0) for el in ev]))
        holidaytree.holidaygroup.append(hol)

    print etree.tostring(holidaytree, pretty_print=True)

#killns_pat = re.compile(
print '\t'.join(sorted([re.sub(r'\{.*\}','',s) for s in alltags.keys()]))

# <holidaygroup holidaytype="national" country="DZ" >
#   <holiday py:for="idx, event in enumerate(cal.xpath('//hcal:Vevent',nslist))"
# 	   py:attrs="list([(evtag,event.xpath('.//hcal:'+evtag'+/text()', nslist))
# 		      for evtag in ('description','dtstart','dtend','rrule/freq')
# 		     ])"
# 	   >
#     <td py:content="event.xpath('.//hcal:description/text()', nslist)" />
#     <td py:content="event.xpath('.//hcal:dtstart/text()',     nslist)" />
#     <td py:content="event.xpath('.//hcal:dtend/text()',       nslist)" />
#     <td py:content="event.xpath('.//hcal:dtend/text()',       nslist)" />
#     <td py:content="event.xpath('.//hcal:dtend/text()',       nslist)" />
#     <td>hi</td>
#   </holiday>
# </holidaygroup>
# </holidays>

# # pull in XML as data structure 
# parser = etree.XMLParser(remove_blank_text=True) 
# lookup = objectify.ObjectifyElementClassLookup() 
# parser.setElementClassLookup(lookup) 
# tree = etree.parse(file, parser) 
# root = tree.getroot() 
# print objectify.dump(tree) 
