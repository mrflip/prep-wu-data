
-- 
--  20081130        users/show      0       1       20081130061556  NYT     _20081130/users/show/NYT.json%3Fpage%3D1+20081130-061556.json
scraped_files = LOAD '/user/flip/tmp/user-listings/_20081126.tsv' using PigStorage('\t') AS (ss, rsrc, id, pg, scraped_at, screen_name, filename);
