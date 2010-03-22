-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTPUT '/data/fixd/social/network/myspace/users_by_lat_lon'       ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- construct distinct users with averaged, rounded lat/long pairs
full_user     = LOAD '$USER' AS (rsrc:chararray, id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;
user          = FOREACH full_user GENERATE id, lat, lon;
user_with_lat_lon = FILTER user BY lat IS NOT NULL AND lon IS NOT NULL;
user_id_group = GROUP user_with_lat_lon BY id;
distinct_user = FOREACH user_id_group GENERATE group AS id, AVG(user_with_lat_lon.lat) AS lat, AVG(user_with_lat_lon.lon) AS lon;
distinct_user_rounded_lat_lon = FOREACH distinct_user GENERATE org.apache.pig.piggybank.evaluation.math.ROUND(lat * 10.0) / 10.0 AS lat, org.apache.pig.piggybank.evaluation.math.ROUND(lon * 10.0	) / 10.0 AS lon ;

-- group by shared lat/long
lat_lon_group   = GROUP distinct_user_rounded_lat_lon BY (lat, lon);
lat_lon_count   = FOREACH lat_lon_group GENERATE group.lat, group.lon, COUNT(distinct_user_rounded_lat_lon);
rmf $OUTPUT
STORE lat_lon_count INTO '$OUTPUT';


                                