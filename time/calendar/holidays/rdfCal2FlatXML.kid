<?xml version="1.0" encoding="utf-8"?>
<holidays xmlns:py="http://purl.org/kid/ns#">
<?python

from lxml import etree 		
from lxml import objectify
from urllib2 import urlopen

# Load file
uri  = "holidays-Algeria.xml"
file = open(uri)  # or sub in urlopen
cal  = etree.ElementTree(file=open(uri))

# Namespaces
nslist = {'rdf' :"http://www.w3.org/1999/02/22-rdf-syntax-ns#",
	  'hcal':"http://www.w3.org/2002/12/cal/icaltzd#"}

# <!-- # pull in XML as data structure -->
# <!-- parser = etree.XMLParser(remove_blank_text=True) -->
# <!-- lookup = objectify.ObjectifyElementClassLookup() -->
# <!-- parser.setElementClassLookup(lookup) -->
# <!-- tree = etree.parse(file, parser) -->
# <!-- root = tree.getroot() -->
# <!-- print objectify.dump(tree) -->

#    tr py:for="event in cal.xpath('//hcal:Vevent',nslist)"
?>

<holidaygroup holidaytype="national" country="DZ" >
  

  <holiday py:for="idx, event in enumerate(cal.xpath('//hcal:Vevent',nslist))"
	   py:attrs="list([(evtag,event.xpath('.//hcal:'+evtag'+/text()', nslist))
		      for evtag in ('description','dtstart','dtend','rrule/freq')
		     ])"
	   >
    <td py:content="event.xpath('.//hcal:description/text()', nslist)" />
    <td py:content="event.xpath('.//hcal:dtstart/text()',     nslist)" />
    <td py:content="event.xpath('.//hcal:dtend/text()',       nslist)" />
    <td py:content="event.xpath('.//hcal:dtend/text()',       nslist)" />
    <td py:content="event.xpath('.//hcal:dtend/text()',       nslist)" />
    <td>hi</td>
  </holiday>
  
</holidaygroup>
</holidays>
