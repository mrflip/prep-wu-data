#!/usr/local/bin/python

import 	csv
from 	vzgutil.NamedTuple			import 	NamedTuple
from	vzgutil.RawFixUtil			import	fixForSQL
from	struct						import	unpack
from	weather.WeatherStation		import	*

def getWeatherStationInfo_ISH(filename):
	print ('Reading '+filename)
	wstns = []	
   	wstnfile = open(filename, 'r')
	# Eat up header stuff
	for i in range(12): wstnfile.readline()
	
	# Pull in each line
	# Flat file format
	#      USAF   NCDC  STATION NAME                  CTRY  ST CALL LAT    LON    ELEV(.1M)
	#      010010 99999 JAN MAYEN                     NO JN    ENJA  +70933 -008667 +00090
	#      123456 12345 12345678901234567890123456789 12 12 12 1234  123123 1234123 123456
	fmt	= "6sx    5sx   29sx                          2sx2sx2sx4sxx  6sx    7sx     6s";
	for line in wstnfile.readlines():
		if len(line) < 79: continue
		line = line.rstrip('\r\n');
		# Unpack flat record
		flatFields = unpack(fmt, line);
		flatFields = tuple(f.rstrip() for f in flatFields)
		flatFields = WeatherStation_ISH.fixnulls(flatFields)
		wstn = WeatherStation_ISH(*flatFields)
		wstns.append(wstn)
	return wstns;


def getWeatherStationInfo_COOP(filename):
	print ('Reading '+filename)
	wstns = []	
   	wstnfile = open(filename, 'r')
	# Eat up header stuff
	# -- none -- 
	
	# Pull in each line
	#      356032 01 24272                       UNITED STATES        OR LINCOLN                        +8    NEWPORT                        NEWPORT                        19530721 19630129  44 38 00 -124 04 00    124    132  2 8 CITYBLOCK S COOP                                               124  
	#                61702       NSTU            AMERICAN SAMOA       AS WESTERN (DISTRICT)                   TAFUNA AMERICAN SAMO           TAFUNA AMERICAN SAMO           19400501 19500531 -14 20 00 -170 41 00 -99999     10  0                                                               -99999
	#      190770 03 14739 72509 BOS  BOS   KBOS UNITED STATES        MA SUFFOLK                        +5    BOSTON WSFO AP                 BOSTON LOGAN INTL AP           19960401 99991231  42 21 38 -071 00 38     20        15 2           ASOS-NWS B ASOS COOP                                 20
	#      123456 12 12345 12345 1234 12345 1234 12345678901234567890 12 123456789012345678901234567890 12345 123456789012345678901234567890 123456789012345678901234567890 12345678 12345678 +DD MM SS +DDD MM SS 123456 123456 12 12345678901 1234567890123456789012345678901234567890123456789 123456
	fmt	= "6sx    2sx5sx   5sx   4sx  5sx   4sx  20sx                 2sx30sx                           5sx   30sx                           30sx                           8sx      8sx      c2sx2sx2sxc3sx 2sx2sx6sx    6sx    2sx11sx        49sx                                              6sxx";
	for line in wstnfile.readlines():
		if len(line) < 287: continue
		line = line.rstrip('\r\n');
		# Unpack flat record
		flatFields = unpack(fmt, line);
		flatFields = tuple(f.rstrip() for f in flatFields[0:-1])
		flatFields = WeatherStation_COOP.fixnulls(flatFields)
		wstn = WeatherStation_COOP(*flatFields)
		wstns.append(wstn)
	return wstns;


def getWeatherStationHist_ISH(filename):
	print ('Reading '+filename)
	history = []
   	wstnfile = open(filename, 'r')
	# Eat up header stuff
	for i in range(6): wstnfile.readline()
	
	# Pull in each line
	fmt	= "6sx	 5sx   4sx " + ("6sx "*12);
	for line in wstnfile.readlines():
		if len(line) < 102: continue
		line = line.rstrip('\r\n');
		# Unpack flat record
		flatFields = unpack(fmt, line);
		(id_USAF, id_NCDC, year) = flatFields[0:3]
		for (month, n_records) in zip(range(1,12+1), flatFields[3:]):
			#history[(id_USAF, id_NCDC)]
			history.append(WeatherStationHistory(id_USAF, id_NCDC, year, month, n_records))
	return history;

def dumpSQLCSV(filename, records):
	print ('Writing '+filename)
	writer = csv.writer(open(filename, "wb"))
	for record in records:
		vals = [fixForSQL(getattr(record, slot)) for slot in record.__slots__]
		writer.writerow(vals)

dir = '/work/DataSources/Data_Weather/'
wstns_COOP 		= getWeatherStationInfo_COOP(dir+'stationlist/'+'StationList-WBAN.txt')
dumpSQLCSV(dir+'sqlcsv/'+'StationList-COOP-Station.csv', wstns_COOP)
wstns_ISH 		= getWeatherStationInfo_ISH (dir+'stationlist/'+'StationList-ISH-Stations.txt')
dumpSQLCSV(dir+'sqlcsv/'+'StationList-ISH-Station.csv',  wstns_ISH)
wstns_ISH_hist 	= getWeatherStationHist_ISH (dir+'stationlist/'+'StationList-ISH-History.txt')
dumpSQLCSV(dir+'sqlcsv/'+'StationList-ISH-History.csv',  wstns_ISH_hist)
