DROP TABLE IF EXISTS  `day_avgs`;
CREATE TABLE	      `day_avgs` (
  wdate date,
  avg_temp decimal(5,2),
  min_temp decimal(5,2),
  max_temp decimal(5,2),
  n_stations INTEGER,
  INDEX         avg_temp         (`avg_temp`),
  INDEX         max_temp         (`max_temp`),
  INDEX         min_temp         (`min_temp`),
  PRIMARY KEY   `wdate`
) ENGINE=MyISAM PACK_KEYS=0 DEFAULT CHARSET=utf8
;

-- SELECT AVG(max_temp) AS avg_max_temp, MIN(max_temp) AS min_max_temp, MAX(max_temp) AS max_max_temp, stns.station_name, 
-- GROUP_CONCAT( CONCAT(stns.station_name, ": ", CAST(max_temp AS CHAR)) ORDER BY station_name),
-- w.* FROM weather_days w, imw_weather_ncdc.stations stns 
-- WHERE stns.wmo = w.wmo AND stns.wban = w.wban AND austin_dist < 0.3
--  AND 	wdate > '2008-01-01' 
-- GROUP BY wdate HAVING max_max_temp >= 100.0
-- ORDER BY avg_max_temp
-- ;

-- Assemble a continuous record
SELECT COUNT(*), min(wdate), max(wdate), YEAR(wdate) AS wyear, station_name, stns.wmo, stns.wban, stns.austin_dist
FROM weather_days w, imw_weather_ncdc.stations stns 
WHERE stns.wmo = w.wmo AND stns.wban = w.wban 
AND ( (austin_dist < 0.08) OR (w.wban = 13904 AND YEAR(wdate) = 1999 AND wdate BETWEEN '1999-05-24' AND '1999-12-31') )
GROUP BY wyear, station_name ASC
;

-- take one reading per day into simplified table
REPLACE INTO day_avgs (wdate, avg_temp, min_temp, max_temp, n_stations)
SELECT wdate,
  avg_temp, 
  min_temp,
  max_temp, 
  count(*) AS n_stations
FROM imw_weather_ncdc.weather_days w, imw_weather_ncdc.stations stns 
WHERE stns.wmo = w.wmo AND stns.wban = w.wban 
AND ( (w.wban = 13958) OR (w.wban = 13904 AND YEAR(wdate) = 1999 AND wdate BETWEEN '1999-05-24' AND '1999-12-31') )
GROUP BY wdate
;

-- -- Or instead, do a spatially-weighted average
-- REPLACE INTO day_avgs (wdate, avg_temp, min_temp, max_temp, n_stations)
-- SELECT wdate,
--   1.0*SUM((1.0/austin_dist) *     temp)/SUM((1.0/austin_dist)) AS avg_temp, 
--   1.0*SUM((1.0/austin_dist) * min_temp)/SUM((1.0/austin_dist)) AS min_temp,
--   1.0*SUM((1.0/austin_dist) * max_temp)/SUM((1.0/austin_dist)) AS max_temp, 
--   count(*) AS n_stations
-- FROM imw_weather_ncdc.weather_days w, imw_weather_ncdc.stations stns 
-- WHERE stns.wmo = w.wmo AND stns.wban = w.wban 
-- GROUP BY wdate
-- ;

SELECT year(wdate) AS wyear, COUNT(*), 
  SUM(if(max_temp >=  90, 1, 0)) AS over_90s,
  SUM(if(max_temp >=  95, 1, 0)) AS over_95s,
  SUM(if(max_temp >= 100, 1, 0)) AS over_100s,
  ROUND(100 * SUM(if(max_temp >= 100, 1, 0)) / SUM(if(max_temp >= 90, 1, 0))) AS when_its_hot_its_damn_hot, 
  SUM(if(min_temp <=  42, 1, 0)) AS under_42s,
  SUM(if(min_temp <=  37, 1, 0)) AS under_37s,
  SUM(if(min_temp <=  32, 1, 0)) AS under_32s,
  ROUND(100 * SUM(if(min_temp <=  32, 1, 0)) / SUM(if(min_temp <=  42, 1, 0))) AS when_its_cold_its_damn_cold
FROM day_avgs d
GROUP BY wyear


-- SELECT COUNT(*), YEAR(wdate) AS wyear, station_name, stns.wmo, stns.wban
-- FROM weather_days w, imw_weather_ncdc.stations stns 
-- WHERE stns.wmo = w.wmo AND stns.wban = w.wban 
-- GROUP BY wyear ASC, station_name ASC
-- ;

