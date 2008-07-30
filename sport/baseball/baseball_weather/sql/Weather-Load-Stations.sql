 -- Name of database
 use vizsagedb_weather; 

 -- =========================================================================
 --
 --	  Define GameEvents Table
 --
 -- =========================================================================

-- 23112-0-0--1995-01-01		13985-1994-04-01-789.432	93868-0-1931-04-01-9.144	23112-0-1942-03-01-569.0616
-- 11633-0-1978-02-01-21.0312	13894-0-1933-04-01			93026-0-1931-11-01			23263-0-1940-07-01
-- 93134-45115-1964-07-13		23256-43164-1955-11-01		13832-0-1943-09-01			
-- NULL,13877,1934-07-01
-- NULL,13891,1937-01-01
-- NULL,14771,1929-07-01
-- NULL,14771,1938-01-01
-- NULL,24037,1893-01-01
-- NULL,24155,1928-06-01
-- NULL,24229,1928-09-01
-- NULL,94224,1899-01-01

 -- TODO:
 -- Split off the mostly-invariant rows
 -- Find correlated rows and convert to 'NULL'?
 -- Build Fielder table
 -- Pivot res_batter_ID, res_batter_hand, res_pitcher_ID, rres_pitcher_hand, esp_rnr1_pitcher_ID, resp_rnr2_pitcher_ID, resp_rnr3_pitcher_ID

DROP TABLE IF EXISTS StationInfoISH;
CREATE TABLE StationInfoISH (
	ID_USAF			INTEGER		UNSIGNED	NOT NULL
 ,	ID_NCDC			INTEGER		UNSIGNED	NOT NULL
 ,	name			CHAR(29)				NOT NULL			
 ,	region			CHAR(2)
 ,	country			CHAR(2)				
 ,	state			CHAR(2)
 ,	callsign		CHAR(4)
 ,	lat				DOUBLE
 ,	lng				DOUBLE
 ,	elev			DOUBLE
 , PRIMARY KEY	ID	(ID_NCDC, ID_USAF)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


DROP TABLE IF EXISTS StationInfoCOOP;
CREATE TABLE StationInfoCOOP (
	ID_COOP			INTEGER		UNSIGNED	
 ,	ID_cd			TINYINT		UNSIGNED
 ,	ID_NCDC			INTEGER		UNSIGNED	NOT NULL
 ,	ID_WMO			INTEGER		UNSIGNED
 ,	ID_FAA			CHAR(4)
 ,	ID_NWS			CHAR(5)
 ,	ID_ICAO			CHAR(4)
 ,	country			CHAR(20)
 ,	state			CHAR(2)
 ,	uscounty		CHAR(30)
 ,	tz				TINYINT
 ,	name_coop		CHAR(30)
 ,	name			CHAR(30)
 ,	svc_beg			DATE
 ,	svc_end			DATE
 ,	lat				DOUBLE
 ,	lng				DOUBLE
 ,	elevgd			DOUBLE
 ,	elev			DOUBLE
 ,	elevtype		TINYINT		UNSIGNED
 ,	reloc			CHAR(11)
 ,	stntype			CHAR(49)
 , PRIMARY KEY	ID	(ID_NCDC, svc_beg)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


DROP TABLE IF EXISTS StationHistISH;
CREATE TABLE StationHistISH (
	ID_USAF			INTEGER		UNSIGNED	NOT NULL
 ,	ID_NCDC			INTEGER		UNSIGNED	NOT NULL
 ,	year			SMALLINT	UNSIGNED
 ,	month			SMALLINT	UNSIGNED
 ,	n_records		INTEGER		UNSIGNED
 , PRIMARY KEY	ID	(ID_NCDC, ID_USAF, year, month)
 ) \
	ENGINE=MyISAM			\
	ROW_FORMAT=FIXED		\
	DEFAULT CHARSET=utf8	\
	COLLATE=utf8_general_ci	\
	;
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;



LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/StationList-ISH-Station.csv' 	
		INTO TABLE StationInfoISH
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;

LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/StationList-COOP-Station.csv' 	
		INTO TABLE StationInfoCOOP
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;


LOAD DATA INFILE '/work/DataSources/Data_Weather/sqlcsv/StationList-ISH-History.csv' 	
		INTO TABLE StationHistISH
		FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES	TERMINATED BY '\r\n';
SHOW COUNT(*) WARNINGS; SHOW COUNT(*) ERRORS; SHOW WARNINGS; SHOW ERRORS;
