-- DROP TABLE IF EXISTS  `stations`;
-- CREATE TABLE	      `stations` (
--   `id`                           INTEGER AUTO_INCREMENT,
--   `wmo`                         MEDIUMINT UNSIGNED,
--   `wban`                         MEDIUMINT UNSIGNED,
--   `lat`                          DECIMAL(5,3),
--   `lng`                          DECIMAL(6,3),
--   `austin_dist`                  DECIMAL(6,3),
--   `station_name`                 VARCHAR(30) CHARACTER SET ASCII,
-- 
--   UNIQUE INDEX stn_id           (`wmo`, `wban`),
--   INDEX        lat_lng          (`lat`,  `lng`),
--   INDEX        austin_dist      (`austin_dist`),
--   PRIMARY KEY	(`id`)
-- ) ENGINE=MyISAM PACK_KEYS=0 DEFAULT CHARSET=utf8
-- ;
-- 
-- LOAD DATA INFILE '~/ics/pool/weather/ncdc/austin_weather/station_info.tsv'
--   REPLACE INTO TABLE        `stations`
--   COLUMNS
--     TERMINATED BY           '\t'
--     OPTIONALLY ENCLOSED BY  ''
--     ESCAPED BY              '\\'
--   (wmo, wban, lat, lng, austin_dist, station_name)
--   ;
-- SELECT 'stations', NOW(), COUNT(*) FROM `stations`;
-- 
-- DROP TABLE IF EXISTS  `weather_days`;
-- CREATE TABLE	      `weather_days` (
--   wmo			INTEGER,
--   wban			INTEGER,
--   wdate			DATE,
--   temp			DECIMAL(5,1),
--   temp_ct		TINYINT,
--   dewp			DECIMAL(5,1),
--   dewp_ct		TINYINT,
--   slp			DECIMAL(5,1),
--   slp_ct		TINYINT,
--   stp			DECIMAL(5,1),
--   stp_ct		TINYINT,
--   visib			DECIMAL(5,1),
--   visib_ct		TINYINT,
--   wdsp			DECIMAL(5,1),
--   wdsp_ct		TINYINT,
--   mxspd			DECIMAL(5,1),
--   gust			DECIMAL(5,1),
--   max_temp		DECIMAL(5,1),
--   max_temp_flag		BOOLEAN,
--   min_temp		DECIMAL(5,1),
--   min_temp_flag		BOOLEAN,
--   precip		DECIMAL(5,2),
--   precip_flag		BOOLEAN,
--   snow_depth		DECIMAL(5,1),
--   fog			BOOLEAN,
--   rain_or_drizzle	BOOLEAN,
--   snow_or_ice		BOOLEAN,
--   hail			BOOLEAN,
--   thunder		BOOLEAN,
--   tornado		BOOLEAN,
--   INDEX        stn_id           (`wmo`, `wban`),
--   PRIMARY KEY   stn_id_date      (`wmo`, `wban`, `wdate`)
-- ) ENGINE=MyISAM PACK_KEYS=0 DEFAULT CHARSET=utf8
-- ;

LOAD DATA INFILE '/data/working/rawd/weather/ncdc/austin_weather/rawd/tables/more.tsv'
  REPLACE INTO TABLE        `weather_days`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  ''
    ESCAPED BY              '\\'
  (@dummy,
  wmo, wban, wdate, temp, temp_ct, dewp, dewp_ct, slp, slp_ct, stp, stp_ct, visib, visib_ct, wdsp, wdsp_ct, mxspd, gust, max_temp, max_temp_flag, min_temp, min_temp_flag, precip, precip_flag, snow_depth, fog, rain_or_drizzle, snow_or_ice, hail, thunder, tornado)
  ;
SELECT 'weather_days', NOW(), COUNT(*) FROM `weather_days`

-- UPDATE imw_weather_ncdc.weather_days SET temp       = NULL WHERE temp       = 9999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET dewp       = NULL WHERE dewp       = 9999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET slp        = NULL WHERE slp        = 9999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET stp        = NULL WHERE stp        = 9999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET visib      = NULL WHERE visib      =  999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET wdsp       = NULL WHERE wdsp       =  999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET mxspd      = NULL WHERE mxspd      =  999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET gust       = NULL WHERE gust       =  999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET max_temp   = NULL WHERE max_temp   = 9999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET min_temp   = NULL WHERE min_temp   = 9999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET snow_depth = NULL WHERE snow_depth =  999.9	;
-- UPDATE imw_weather_ncdc.weather_days SET precip     = NULL WHERE precip     =   99.99	;
