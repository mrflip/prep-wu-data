#!/usr/bin/python
from glob import glob
import re
from monkeywrench.convert import FlatFile                           

#			                 U.T.
#			               Greatest    Saros          Pen.   Umb. S.D. S.D.  GST    Moon  Moon
#			        Date    Eclipse Type #    Gamma   Mag.   Mag. Par  Tot  (0 UT)   RA    Dec
#                                                                            h     h      &#176;
#            #  0006 Aug 27  10:57   P   57   0.697  1.581  0.608  78m   -   22.2  22.21 -10.5
flatfmt    = "xi5   |s3 |I2x|I2|I2xx|s2x|I2|d7     |d6    |d6    |I3 x|I3x|d5    |d6    |d5"
dataNames = "_dYear _dMo _dDay _hr _min eclipseType sarosNumber eclipseGamma magPenumbralMag magUmbral \
	  		  semidurationPartial semidurationTotal siderealGST moonRightAsc moonDeclination".split()
datafiles = "sunearth.gsfc.nasa.gov-eclipse-LEcat/LE*.html"
datafile   = FlatFile(flatfmt)

#print ' -- '.join(["%s: %s"%(s,t) for (s,t) in datafile.types(dataNames)])
#print datafile.lineRegexp()

lineRE = datafile.lineRegexp()
for filename in glob(datafiles):
	file = open(filename)
	for line in (file.readlines()):  
		match = re.search(lineRE, line)
		if (match): print ','.join(match.groups())