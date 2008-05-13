use vizsagedb_aux;
DROP TABLE IF EXISTS CountryISOCodes;
CREATE TABLE         CountryISOCodes (
  `isocode` 	CHAR(2) 	UNIQUE NOT NULL,
  `country`	CHAR(50)	NOT NULL,
  PRIMARY KEY             (`isocode`),
  INDEX 	`country` (`country`)
) ENGINE=MYISAM CHARACTER SET utf8 PACK_KEYS=1 ROW_FORMAT=FIXED
  COMMENT = 'ISO 3166-1 alpha-2 country codes; see http://www.iso.org/iso/en/prods-services/iso3166ma/ (from Paul Eggert by way of the zoneinfo project)'
;

LOAD DATA INFILE 
        '/Users/flip/now/vizsage/apps/AuxData/AuxTable-CountryISOCodes.flat'
        REPLACE INTO TABLE `CountryISOCodes`
        FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n'
	IGNORE 23 LINES
;

DROP TABLE IF EXISTS CountryTZLatLng;
CREATE TABLE         CountryTZLatLng (
  `isocode` 	CHAR(2)          	NOT NULL,
  `tzName`	CHAR(35)	   	NOT NULL,
  `lat`         DOUBLE                  NOT NULL,
  `lng`         DOUBLE                  NOT NULL,
  `comment`	VARCHAR(100)            NOT NULL DEFAULT '',
  PRIMARY KEY             (`tzName`),
  INDEX 	`isocode`  (`isocode`),
  INDEX 	`lat`     (`lat`),
  INDEX 	`lng` 	  (`lng`)
) ENGINE=MYISAM CHARACTER SET utf8 PACK_KEYS=1
  COMMENT = 'ISO 3166-1 alpha-2 country codes; see http://www.iso.org/iso/en/prods-services/iso3166ma/ (from Paul Eggert by way of the zoneinfo project)'
;

LOAD DATA INFILE 
        '/Users/flip/now/vizsage/apps/AuxData/AuxTable-CountryTZLatLng.csv'
        REPLACE INTO TABLE `CountryTZLatLng`
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
        LINES  TERMINATED BY '\n'
;
