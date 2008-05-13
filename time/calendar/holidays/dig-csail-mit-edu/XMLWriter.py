#!/usr/bin/python
""" $Id: XMLWriter.py 433 2007-12-09 15:53:02Z mrflipco $
A Sax Handler for writing XML tags, attributes, and data characters.

see changelog at end
"""

import re

#cf  Python/XML HOWTO
# The Python/XML Special Interest Group
# xml-sig@python.org 
# (edited by akuchling@acm.org)
# http://www.python.org/doc/howto/xml/xml-howto.html
#
#cf debian python-xml 0.5.1-5 (release date?)
#
# Hmm... we don't actually depend on anything from saxlib
#from xml.sax.saxlib import DocumentHandler, AttributeList


class T:
    """
    conforms to saxlib.DocumentHandler interface
    
    """

    def __init__(self, outFp):
	self._outFp = outFp
	self._elts = []
	self._empty = 0 # just wrote start tag, think it's an empty element.

    #@@ on __del__, close all open elements?

    def startElement(self, n, attrs):
	o = self._outFp

	if self._empty: o.write("  >")

	o.write("<%s" % (n,))

	self._attrs(attrs)

	self._elts.append(n)

	o.write("\n%s" % ('  ' * (len(self._elts)-1) ))
	self._empty = 1

    def _attrs(self, attrs):
	o = self._outFp

	for n, v in attrs.items():
	    o.write("\n%s%s=\"" %
		    ((' ' * (len(self._elts) * 2 + 3) ), n))
            doChars(o, v)
            o.write('"')

    def endElement(self, name=None):
	n = self._elts[-1]
	# @@ assert n= name?
	del self._elts[-1]

	o = self._outFp

	if self._empty:
	    o.write("/>")
	    self._empty = 0
	else:
	    o.write("</%s\n%s>" % (n, ('  ' * len(self._elts) )))

    def characters(self, ch, start=0, length=-1):
	#@@ throw an exception if the element stack is empty
	o = self._outFp

	if self._empty:
	    o.write("  >")
	    self._empty = 0

        doChars(o, ch, start, length)


markupChar = re.compile(r"[\n\r<>&]")

def doChars(o, ch, start=0, length=-1):
    if length<0: length = len(ch)
    else: length = start+length

    i = start
    while i < length:
        m = markupChar.search(ch, i)
        if not m:
            o.write(ch[i:])
            break
        j = m.start()
        o.write(ch[i:j])
        o.write("&#%d;" % (ord(ch[j]),))
        i = j + 1


class Attrs:
    """
    conforms to saxlib.AttributeList
    """
    
    def __init__(self, aSequenceOfPairs=()):
	self._attrs = aSequenceOfPairs

    def getLength(self):
	return len(self._attrs)

    def items(self):
        return self._attrs

    def getName(self, i):
	return self._attrs[i][0]

    def getType(self, i):
	raise RuntimeError # not implemented

    def getValue(self, i):
	return self._attrs[i][1]

    def __len__(self):
	return len(self._attrs)

    def __getitem__(self, key):
	if type(key) is type(1):
	    return self.getName(key)
	else:
	    return self.getValue(key)

    def keys(self):
	return map(lambda x: x[0], self._attrs)

    def has_key(self, key):
	for n, v in self._attrs:
	    if key == n: return 1
	return 0

    def get(self, key, alternative):
	for n, v in self._attrs:
	    if key==n: return v
	return alternative

def test():
    import sys
    xwr = T(sys.stdout)

    xwr.startElement('abc', Attrs())
    xwr.startElement('def', Attrs((('x', '1'), ('y', '0'))))
    xwr.startElement('ghi', Attrs())
    xwr.endElement('ghi')
    xwr.characters("abcdef")
    xwr.endElement('def')
    xwr.endElement('abc')

if __name__ == '__main__': test()


# copied from previous projects...
# 2000/10/n3/ Id: XMLWriter.py,v 1.3 2000/11/14 10:14:00 connolly Exp
# Id: notation3.py,v 1.10 2000/10/17 01:08:36 connolly Exp 
# which was taken previously from
# Id: tsv2xml.py,v 1.1 2000/10/02 19:41:02 connolly Exp connolly
# $Log: XMLWriter.py,v $
# Revision 2.3  2004/09/30 14:25:31  connolly
# escape markup chars in attribute values too
#
# Revision 2.2  2004/03/25 17:24:42  connolly
# removed dependency on saxlib
#
