for foo in ASOSLST.XLS COOP-ACT.TXT COOP-STATE-CODES.TXT COOP.TXT.Z COUNTRY-LIST.TXT DIV-AREA.TXT ISH-HISTORY.TXT ISH-HISTORY.xls ISH-INVENTORY.TXT.Z ISH-PROBLEMS.TXT MASTER-STN-HIST.ZIP NEXRAD-DESCRIPTION.TXT README.TXT STATION-HIST.ZIP WBAN-FMT.TXT WBAN-MSC.TXT WBAN.TXT.Z country-list-fips.txt inswo-stns.txt ish-problems.txt ish-qc-stats2.txt mscdat.txt product-inventory.xls readme.txt stnhist-stn-num.txt us-historical-list.txt ; do
  echo "getting $foo"
  wget -r -l5  --no-clobber --no-parent  --no-remove-listing -A.txt,.TXT,.XLS,.xls,.ZIP    \
      --no-verbose -a ./ftp.ncdc.noaa.gov/wget-`date +%Y%m%d`.log        \
      ftp://ftp.ncdc.noaa.gov/pub/data/inventories/"$foo"
done      

# * ASOS STATION LIST (200.0Kbytes)
#   MS Excel File--A list of all U.S. ASOS stations for which NCDC receives and processes data.
#
# * COOPERATIVE STATIONS INDEX (13Mbytes)
#   Historical cooperative station index. Cooperative stations are U.S. stations operated by local observers which generally report max/min temperatures and precipitation. National Weather Service (NWS) data are also included in this dataset. The data receive extensive automated + manual quality control. The index includes a county location cross-reference. Over 8000 stations are currently active across the country. *** Due to file size, users should 'load to local disk' (right mouse button on many browsers) instead of attempting to read entire file into memory. See cooperative active stations index below for smaller file with only the currently active stations included. Both files have header record to identify columns for: Cooperative, WBAN, and WMO station numbers; FAA, NWS, and ICAO call letters; country, state, county, time zone, station name, latitude (degrees-minutes-seconds, north=positive, south=negative), longitude (degrees-minutes-seconds, east=positive, west=negative), and elevation (in feet).
# 
# * COOPERATIVE STATIONS INDEX (COMPRESSED) (1.5Mbytes)
#   Same as above but compressed for quicker download. Use Winzip or gunzip to uncompress.
#
#
# * COOPERATIVE STATIONS INDEX--ACTIVE STATIONS (1.9Mbytes)
#   Same as Index above but only includes stations that are still active, thereby providing a much smaller file for downloading.
#
#
# * COOPERATIVE STATIONS MAP (35.0Kbytes)
#   A 'gif' image map with locations of all currently active cooperative stations in the continental U.S. plotted.
#
# * COOPERATIVE STATIONS STATE CODES ( 772bytes) The 2-digit numbers for each
#   state which correspond to the first 2 digits of the cooperative station
#   numbers.
#
# * U.S. CLIMATE DIVISIONS ( 4174bytes) The square mileage in each climate
#   division, by state (i.e., the individual area weights applied to each
#   division for climatological summaries). Note: if area weight = 0 for
#   climatological purposes, then the square mileage is shown as 0.
#
# * *** GLOBAL HOURLY SURFACE DATA INFORMATION: ***
#       o Use the global country list below to identify the countries (including
#       U.S.) of interest.
#       o Then use the global station list to identify the station(s) of
#       interest.
#       o Finally, use the global surface inventories to obtain month-by-month
#       inventories showing the volume of data available for each station.
#
# * INTEGRATED SURFACE HOURLY (ISH) DATABASE STATION LIST (1.1 Mbytes)
#   Reference showing the station ID's and information for each station in the
#   Federal Climate Complex ISH global database. ISH is a worldwide database of
#   hourly and synoptic data, derived from TD9956 (DATSAV3 global hourly),
#   TD3280 (US hourly), and TD3240 (US hourly precipitation).
#
# * INTEGRATED SURFACE HOURLY (ISH) DATABASE INVENTORY (48 Mbytes)
#   Reference showing the number of observations by station-year-month in the
#   ISH database.
#
# * INTEGRATED SURFACE HOURLY (ISH) DATABASE INVENTORY (9 Mbytes)
#   Compressed listing for quicker download (see above).
#
# * GLOBAL COUNTRY LIST (12.6Kbytes)
#   Reference showing country names and the associated station number ranges
#   assigned for each country. Use with global inventories.
#
# * MASTER STATION HISTORY (29.2 Mbytes)
#   A historical report, updated monthly, that shows station name changes, IDs
#   and locations over time along with relocation information whenever
#   available. Entries are included for cooperative stations since 1948, as well
#   as all US CRN stations, some ASOS and other surface observing sites.
#
# * MASTER STATION HISTORY--ZIPPED (2,513 Kbytes)
#   PK-zipped version of the Master Station History.
#
# * MASTER STATION HISTORY (DOCUMENTATION) (2.3 Kbytes)
#   Documentation for the layout of the Master Station History report.
# * NATIONAL WEATHER SERVICE (NWS) STATION HISTORIES (5.1Mbytes)
#   A Wordperfect-5 file with station history summaries for all NWS
#   locations--includes exact station location, anemometer height, etc. *** Use
#   'load to local disk' (right mouse button on many browsers) due to file size.
# * NATIONAL WEATHER SERVICE (NWS) STATION HISTORIES--ZIPPED (880Kbytes)
#   PK-zipped version of the NWS station histories file.
#
# * NWS-USAF-NAVY STATION LIST (5.4Mbytes )
#   Historical WBAN index. WBAN's are forms received here at NCDC for National
#   Weather Service and U.S. military stations. This is an index of these
#   locations--many of which have hourly data in digital form. Additional hourly
#   type stations are included in the global surface inventories above. See
#   format file below for format documentation.
# * NWS-USAF-NAVY STATION LIST (COMPRESSED) (500Kbytes)
#   Same as above but compressed for quicker download. Use Winzip or gunzip to
#   uncompress.
#
# * NWS-USAF-NAVY STATION LIST FORMAT (1.0Kbytes)
#   Format layout for the NWS-USAF-Navy station list.
#
# * WBAN-WMO CROSS REFERENCE (125Kbytes)
#   WBAN-AWSMSC cross reference--the WBAN index and TD9956 (both mentioned
#   above) cross-referenced with each other.



# ASOSLST.XLS 			# -rw-r--r--   1 ftp      aftp       311808 Jul 16  2007     
# COOP-ACT.TXT			# -rw-r--r--   1 ftp      aftp      1794039 Feb  2 01:30 
# COOP-STATE-CODES.TXT		# -rw-rw-r--   1 ftp      aftp          772 Jan 17  1996 
# COOP.TXT.Z			# -rw-r--r--   1 ftp      aftp      3370663 Feb  2 01:30 
# COUNTRY-LIST.TXT		# -rw-r--r--   1 ftp      aftp        12635 Jul  1  1996 
# DIV-AREA.TXT			# -rw-rw-r--   1 ftp      aftp         4122 Feb 19  1998 
# ISH-HISTORY.TXT 		# -rw-r--r--   1 ftp      aftp      2253738 Jan 18 15:52 
# ISH-HISTORY.xls 		# -rw-r--r--   1 ftp      aftp      7582720 Jan 18 15:52 
# ISH-INVENTORY.TXT.Z		# -rw-r--r--   1 ftp      aftp      9683313 Mar 16  2007 
# ISH-PROBLEMS.TXT		# -rw-r--r--   1 ftp      aftp         1317 Jun  6  2006 
# MASTER-STN-HIST.ZIP           # -rw-r--r--   1 ftp      aftp      3310940 Jan  4 14:18 
# NEXRAD-DESCRIPTION.TXT 	# -rw-rw-r--   1 ftp      aftp        27933 Aug 14  1995 
# README.TXT			# -rw-r--r--   1 ftp      aftp         6674 Feb 10  2005 
# STATION-HIST.ZIP		# -rw-rw-r--   1 ftp      aftp       884606 Sep 23  1996 
# WBAN-FMT.TXT			# -rw-rw-r--   1 ftp      aftp         2151 Sep 12  1997 
# WBAN-MSC.TXT			# -rw-rw-r--   1 ftp      aftp        69437 Feb  1  2001 
# WBAN.TXT.Z			# -rw-r--r--   1 ftp      aftp      1150785 Feb  2 01:30 
# country-list-fips.txt		# -rw-r--r--   1 ftp      aftp        26810 Jan 18  2005 
# inswo-stns.txt		# -rw-rw-r--   1 ftp      aftp       120775 Nov 18  1998 
# ish-problems.txt		# -rw-r--r--   1 ftp      aftp         1317 Jun  6  2006 
# ish-qc-stats2.txt		# -rw-r--r--   1 ftp      aftp     56187955 Jan  5  2005 
# mscdat.txt			# -rw-rw-r--   1 ftp      aftp     17345061 Oct 23  1998 
# product-inventory.xls		# -rw-r--r--   1 ftp      aftp       152064 Jan 15 16:01 
# readme.txt			# -rw-r--r--   1 ftp      aftp         6674 Feb 10  2005 
# stnhist-stn-num.txt		# -rw-rw-r--   1 ftp      aftp     12664821 Feb  9  2001 
# us-historical-list.txt	# -rw-rw-r--   1 ftp      aftp      4812040 Jan 15  1997 
#
# ISH-INVENTORY.TXT		# -rw-r--r--   1 ftp      aftp     47819605 Mar 16  2007 
# COOP.TXT			# -rw-r--r--   1 ftp      aftp     17502289 Feb  2 01:30
# WBAN.TXT			# -rw-r--r--   1 ftp      aftp      6441690 Feb  2 01:30 
# MASTER-STN-HIST.TXT		# -rw-r--r--   1 ftp      aftp     37426536 Jan  4 14:18 
#
# GLOBAL-SFC-1900-1998A.TXT	# -rw-rw-r--   1 ftp      aftp      5449885 Feb  1  2001 
# GLOBAL-SFC-1900-1998B.TXT	# -rw-rw-r--   1 ftp      aftp      6761944 Feb  1  2001 
# GLOBAL-SFC-1900-1998C.TXT	# -rw-rw-r--   1 ftp      aftp      5052340 Feb  1  2001 
# GLOBAL-SFC-1900-1998D.TXT	# -rw-rw-r--   1 ftp      aftp      7433098 Feb  1  2001 
# GLOBAL-SFC-1900-1998E.TXT	# -rw-rw-r--   1 ftp      aftp      3774359 Feb  1  2001 
# GLOBAL-SFC-1998.TXT		# -rw-rw-r--   1 ftp      aftp       822767 Feb  1  2001 
# GLOBAL-SFC-1999.TXT		# -rw-rw-r--   1 ftp      aftp       766900 Feb  1  2001 
# GLOBAL-SFC-2000.TXT		# -rw-rw-r--   1 ftp      aftp       741738 Feb  1  2001 
# GLOBAL-SFC-2001.TXT		# -rw-r--r--   1 ftp      aftp       906684 Aug  5  2002 
# GLOBAL-SFC-2002.TXT		# -rw-r--r--   1 ftp      aftp       934952 Mar 21  2003 
# GLOBAL-SFC-2003.TXT		# -rw-r--r--   1 ftp      aftp       862802 Feb  6  2004 
# GLOBAL-SFC-2004.TXT		# -rw-r--r--   1 ftp      aftp       731008 Feb  9  2005 
# TD3280.TXT			# -rw-r--r--   1 ftp      aftp      1834744 Aug  5  2002 
# UPPERAIR.TXT			# -rw-rw-r--   1 ftp      aftp       371897 Jul 17  1995 
