
-- Histogram and CDF for Length of screen name
-- 
SELECT count(*)  INTO @total_records FROM twitter_user_partials tc
;
SELECT raw.len, raw.num, SUM(running.num) AS running_total, 100*( SUM(running.num) /  @total_records ) AS running_pct
FROM	( SELECT length(screen_name) as len, count(*) as num FROM twitter_user_partials t GROUP BY len ) raw,
		( SELECT length(screen_name) as len, count(*) as num FROM twitter_user_partials t GROUP BY len ) running
  WHERE running.len <= raw.len
  GROUP BY raw.len


SELECT length(screen_name) AS len, t.* 
FROM twitter_user_partials t
WHERE length(screen_name) >= 20
ORDER BY len  
