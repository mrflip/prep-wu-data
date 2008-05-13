
# echo "
#  DROP TABLE IF EXISTS vizsagedb_foo.Weather;
#  CREATE TABLE vizsagedb_foo.Weather (
#        dataset		INTEGER UNSIGNED NOT NULL
#   ,    coopid		INTEGER UNSIGNED NOT NULL
#   ,    wbmid		INTEGER UNSIGNED NOT NULL
#   ,    cd		INTEGER UNSIGNED NOT NULL
#   ,    field		CHAR(4)          NOT NULL
#   ,    un		CHAR(2)          NOT NULL
#   ,    datetime		DATE             NOT NULL
#   ,    flag_1		CHAR(1)
#   ,    flag_2		CHAR(1)
#   ,    value		INTEGER UNSIGNED NOT NULL
#   , PRIMARY KEY	dtf	(datetime, field)
#   , INDEX  (value)
#   ) \
#  	ENGINE=MyISAM 			\
#  	ROW_FORMAT=FIXED 		\
#  	DEFAULT CHARSET=utf8 	\
#  	COLLATE=utf8_general_ci	\
#   ;" | time mysql -v -E -h localhost -u vizsagedb -p'mVn34cq,FvKGw::X'

# weathercsv="/work/DataSources/Data_Weather/BostonWeather192008to200708.csv"

# tail +3 3614681175292dat.txt |     perl -ne 'chomp; 
#              ($dataset,$coopid,$wbnid,$cd,$elem,$un,$yearmo,@b)=split ","; 
#        $day=1; 
#        $yearmo = substr($yearmo,0,4)."-".substr($yearmo,4,2);
#        @head=($dataset,$coopid,$wbnid,$cd,$elem,$un); 
#        while (@b) { 
# 	 $dayhr = shift @b; 
#          $day   = substr($dayhr,0,2);
#          $hr    = substr($dayhr,2,2); $hr=0 if ($hr==24);
#          $date = sprintf("%s-%02d %02d:00:00", $yearmo, $day, $hr);
# 	   $val = shift @b; 
# 	   $f1=shift @b; $f1=~s/^\s*$/NULL/; 
# 	   $f2=shift @b; $f2=~s/^\s*$/NULL/; 
#            # $val="NULL" if $val==-99999; 
# 	   next if $val==-99999; 
# 	   print join ",",(@head, $date, $f1,$f2,$val); 
# 	   print "\n"; 
# 	   $day++; 
#        } ' > $weathercsv

# echo "
#   LOAD DATA INFILE '$weathercsv' REPLACE INTO TABLE vizsagedb_foo.Weather
#             FIELDS TERMINATED BY ',' ENCLOSED BY '\\\"' ESCAPED BY '\\\\' 
#             LINES  TERMINATED BY '\n';" | time mysql -v -E -h localhost -u vizsagedb -p'mVn34cq,FvKGw::X'


# Here are the cities with ballparks

# AZ	Phoenix			Phoenix,AZ			
# CA	Anaheim			Anaheim,CA			
# CA	Los Angeles		Los Angeles,CA			
# CA	Oakland			Oakland,CA			
# CA	San Diego		San Diego,CA			
# CA	San Francisco		San Francisco,CA		
# CO	Denver			Denver,CO			
# CT	Hartford		Hartford,CT			
# CT	Middletown		Middletown,CT			
# CT	New Haven		New Haven,CT			
# DC	Washington		Washington,DC			
# DE	Dover			Dover,DE			
# DE	Wilmington		Wilmington,DE			
# FL	Lake Buena Vista	Lake Buena Vista,FL		
# FL	Miami			Miami,FL			
# FL	St. Petersburg		St. Petersburg,FL		
# GA	Atlanta			Atlanta,GA			
# HI	Honolulu		Honolulu,HI			
# IA	Keokuk			Keokuk,IA			
# IL	Chicago			Chicago,IL			
# IL	Rockford		Rockford,IL			
# IN	Fort Wayne		Fort Wayne,IN			
# IN	Indianapolis		Indianapolis,IN			
# KY	Covington		Covington,KY			
# KY	Louisville		Louisville,KY			
# KY	Ludlow			Ludlow,KY			
# MA	Boston			Boston,MA			
# MA	Springfield		Springfield,MA			
# MA 	Worcester		Worcester,MA			
# MD	Baltimore		Baltimore,MD			
# MI	Detroit			Detroit,MI			
# MI	Grand Rapids		Grand Rapids,MI			
# MN	Bloomington		Bloomington,MN			
# MN	Minneapolis		Minneapolis,MN			
# MO	Kansas City		Kansas City,MO			
# MO	St. Louis		St. Louis,MO			
# MX	Monterrey		Monterrey,MX			
# NJ	Gloucester City		Gloucester City,NJ		
# NJ	Harrison		Harrison,NJ			
# NJ	Hoboken			Hoboken,NJ			
# NJ	Jersey City		Jersey City,NJ			
# NJ	Newark			Newark,NJ			
# NJ	Waverly			Waverly,NJ			
# NJ	Weehawken		Weehawken,NJ			
# NJ	West New York		West New York,NJ		
# NV	Las Vegas		Las Vegas,NV			
# NY	Albany			Albany,NY			
# NY	Brooklyn		Brooklyn,NY			
# NY	Buffalo			Buffalo,NY			
# NY	Elmira			Elmira,NY			
# NY	Irondequoit		Irondequoit,NY			
# NY	Maspeth			Maspeth,NY			
# NY	New York		New York,NY			
# NY	Rochester		Rochester,NY			
# NY	St. George		St. George,NY			
# NY	Syracuse		Syracuse,NY			
# NY	Three Rivers		Three Rivers,NY			
# NY	Troy			Troy,NY				
# NY	West Troy		West Troy,NY			
# OH	Canton			Canton,OH			
# OH	Cincinnati		Cincinnati,OH			
# OH	Cleveland		Cleveland,OH			
# OH	Collinwood		Collinwood,OH			
# OH	Columbus		Columbus,OH			
# OH	Dayton			Dayton,OH			
# OH	Geauga Lake		Geauga Lake,OH			
# OH	Pendleton		Pendleton,OH			
# OH	Toledo			Toledo,OH			
# PA	Altoona			Altoona,PA			
# PA	Philadelphia		Philadelphia,PA			
# PA	Pittsburgh		Pittsburgh,PA			
# PR	San Juan		San Juan,PR			
# RI	Providence		Providence,RI			
# RI	Warwick			Warwick,RI			
# TX	Arlington		Arlington,TX			
# TX	Houston			Houston,TX			
# VA	Richmond		Richmond,VA			
# WA	Seattle			Seattle,WA			
# WI	Milwaukee		Milwaukee,WI			
# WV	Wheeling		Wheeling,WV			
# JAP	Tokyo			Tokyo,JAP			
# QUE	Montreal		Montreal,QUE			
# ONT	Toronto			Toronto,ONT			

# for foo in "Phoenix" "Anaheim" "Los Angeles" "Oakland" "San Diego" "San Francisco" "Denver" "Hartford" "Middletown" "New Haven" "Washington" "Dover" "Wilmington" "Lake Buena Vista" "Miami" "St. Petersburg" "Atlanta" "Honolulu" "Keokuk" "Chicago" "Rockford" "Fort Wayne" "Indianapolis" "Covington" "Louisville" "Ludlow" "Boston" "Springfield" "Worcester" "Baltimore" "Detroit" "Grand Rapids" "Bloomington" "Minneapolis" "Kansas City" "St. Louis" "Monterrey" "Gloucester City" "Harrison" "Hoboken" "Jersey City" "Newark" "Waverly" "Weehawken" "West New York" "Las Vegas" "Albany" "Brooklyn" "Buffalo" "Elmira" "Irondequoit" "Maspeth" "New York" "Rochester" "St. George" "Syracuse" "Three Rivers" "Troy" "West Troy" "Canton" "Cincinnati" "Cleveland" "Collinwood" "Columbus" "Dayton" "Geauga Lake" "Pendleton" "Toledo" "Altoona" "Philadelphia" "Pittsburgh" "San Juan" "Providence" "Warwick" "Arlington" "Houston" "Richmond" "Seattle" "Milwaukee" "Wheeling" "Tokyo" "Montreal" "Toronto" ""; do
#     grep -i "$foo" /work/DataSources/Data_Geo/ZIP_CODES.txt
# done


# echo "
#   DROP TABLE IF EXISTS vizsagedb_foo.ZipCodes;
#   CREATE TABLE vizsagedb_foo.ZipCodes (
#        zip		INTEGER UNSIGNED 	NOT NULL
#   ,    lat		FLOAT			NOT NULL
#   ,    lng		FLOAT			NOT NULL
#   ,    city		VARCHAR(26)		NOT NULL
#   ,    state		CHAR(2)			NOT NULL
#   ,    county		VARCHAR(25)		NOT NULL
#   ,    deliv		VARCHAR(11)		NOT NULL
#   , PRIMARY KEY	zip	(zip)
#   , INDEX		(city)
#   , INDEX		(state)
#   , INDEX		(county)
#   , INDEX		(lat)
#   , INDEX		(lng)
#   ) \
#  	ENGINE=MyISAM 		\
#  	ROW_FORMAT=FIXED 	\
#  	DEFAULT CHARSET=utf8 	\
#  	COLLATE=utf8_general_ci	\
#   ;" | time mysql -v -E -h localhost -u vizsagedb -p'mVn34cq,FvKGw::X'

# zipcsv="/work/DataSources/Data_Geo/ZIP_CODES.txt"

# echo "
#   LOAD DATA INFILE '$zipcsv' REPLACE INTO TABLE vizsagedb_foo.ZipCodes
#             FIELDS TERMINATED BY ',' ENCLOSED BY '\\\"' ESCAPED BY '\\\\' 
#             LINES  TERMINATED BY '\r\n';" | time mysql -v -E -h localhost -u vizsagedb -p'mVn34cq,FvKGw::X'


echo "
  DROP TABLE IF EXISTS vizsagedb_rsnew.Sites;
  CREATE TABLE vizsagedb_rsnew.Sites (
       siteID		CHAR(5) 	 	NOT NULL
  ,    name		VARCHAR(60)		NOT NULL
  ,    aka		VARCHAR(60)		
  ,    city		VARCHAR(26)		NOT NULL
  ,    state		CHAR(2)			NOT NULL
  ,    start		DATE			NOT NULL
  ,    end		DATE			DEFAULT NULL
  ,    leagueID		VARCHAR(3)		
  ,    comment		VARCHAR(150)		NOT NULL
  , PRIMARY KEY	siteID	(siteID)
  , INDEX		(name)
  , INDEX		(aka)
  , INDEX		(city)
  , INDEX		(state)
  , INDEX		(start)
  , INDEX		(end)
  , INDEX		(leagueID)
  ) \
 	ENGINE=MyISAM 		\
 	ROW_FORMAT=FIXED 	\
 	DEFAULT CHARSET=utf8 	\
 	COLLATE=utf8_general_ci	\
  ;" | time mysql -v -E -h localhost -u vizsagedb -p'mVn34cq,FvKGw::X'

sitecsv="/work/DataSources/Data_MLB/retrosheet/misc_src/parkcodes.sqlload"

echo "
  LOAD DATA INFILE '$sitecsv' REPLACE INTO TABLE vizsagedb_rsnew.Sites
            FIELDS TERMINATED BY ',' ENCLOSED BY '\\\"' ESCAPED BY '\\\\' 
            LINES  TERMINATED BY '\n';" | time mysql -v -E -h localhost -u vizsagedb -p'mVn34cq,FvKGw::X'

