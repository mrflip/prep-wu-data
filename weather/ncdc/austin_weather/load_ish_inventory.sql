-- DROP TABLE IF EXISTS  `ish_inventory`;
-- CREATE TABLE	      `ish_inventory` (
--   `id`                           INTEGER AUTO_INCREMENT,
--   `usaf`                         MEDIUMINT UNSIGNED,
--   `wban`                         MEDIUMINT UNSIGNED,
--   `wyear`                        SMALLINT UNSIGNED,
--   `m01`                          SMALLINT UNSIGNED,
--   `m02`                          SMALLINT UNSIGNED,
--   `m03`                          SMALLINT UNSIGNED,
--   `m04`                          SMALLINT UNSIGNED,
--   `m05`                          SMALLINT UNSIGNED,
--   `m06`                          SMALLINT UNSIGNED,
--   `m07`                          SMALLINT UNSIGNED,
--   `m08`                          SMALLINT UNSIGNED,
--   `m09`                          SMALLINT UNSIGNED,
--   `m10`                          SMALLINT UNSIGNED,
--   `m11`                          SMALLINT UNSIGNED,
--   `m12`                          SMALLINT UNSIGNED,
-- 
--   UNIQUE INDEX stn_id           (`usaf`, `wban`, `wyear`),
--   INDEX        wyear            (`wyear`),
--   PRIMARY KEY	(`id`)
-- ) ENGINE=MyISAM PACK_KEYS=0 DEFAULT CHARSET=utf8
-- ;
-- 
-- LOAD DATA INFILE '~/ics/pool/weather/ncdc/austin_weather/ish/ish-inventory.tsv'
--   REPLACE INTO TABLE        `ish_inventory`
--   COLUMNS
--     TERMINATED BY           '\t'
--     OPTIONALLY ENCLOSED BY  ''
--     ESCAPED BY              '\\'
--   (usaf, wban, wyear, m01, m02, m03, m04, m05, m06, m07, m08, m09, m10, m11, m12)
--   ;
-- SELECT 'ish_inventory', NOW(), COUNT(*) FROM `ish_inventory`;


DROP TABLE IF EXISTS  `ish_stations`;
CREATE TABLE	      `ish_stations` (
  `id`                          INTEGER AUTO_INCREMENT,
  `wmo`                         MEDIUMINT UNSIGNED,
  `wban`                        MEDIUMINT UNSIGNED,
  `lat`                         DECIMAL(5,3),
  `lng`                         DECIMAL(6,3),
  `elev`                        DECIMAL(6,3),
  `ct_wmo`                      CHAR(2) CHARACTER SET ASCII,
  `ct_fips`                     CHAR(2) CHARACTER SET ASCII,
  `st`                          CHAR(2) CHARACTER SET ASCII,
  `icao`                        CHAR(4) CHARACTER SET ASCII,
  `station_name`                VARCHAR(30) CHARACTER SET ASCII,
  `austin_dist`                 DECIMAL(6,3),

  UNIQUE INDEX stn_id           (`wmo`,    `wban`),
  INDEX        lat_lng          (`lat`,    `lng`),
  INDEX        austin_dist      (`austin_dist`),
  INDEX        ct_wmo_st        (`ct_wmo`,  st),
  INDEX        ct_fips_st       (`ct_fips`, st),
  PRIMARY KEY	(`id`)
) ENGINE=MyISAM PACK_KEYS=0 DEFAULT CHARSET=utf8
;

LOAD DATA INFILE '~/ics/pool/weather/ncdc/austin_weather/rawd/ish-history.tsv'
  REPLACE INTO TABLE        `ish_stations`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  ''
    ESCAPED BY              '\\'
  (wmo, wban, lat, lng, elev, ct_wmo, ct_fips, st, icao, station_name, austin_dist)
  ;
SELECT 'ish_stations', NOW(), COUNT(*) FROM `ish_stations`;

