-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTPUT '/data/fixd/social/network/myspace/users_by_zip'           ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- load user data
full_user     = LOAD '$USER' AS (rsrc:chararray, person_id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;

-- filter by a well-formed lat/long pair
user 	      = FOREACH full_user GENERATE lat, lon;
user_lat_lon  = FILTER user BY lat IS NOT NULL AND lon IS NOT NULL;
user_rounded_lat_lon = FOREACH user_lat_lon GENERATE org.apache.pig.piggybank.evaluation.math.ROUND(lat * 10.0) / 10.0 AS lat, org.apache.pig.piggybank.evaluation.math.ROUND(lon * 10.0) / 10.0 AS lon ;
grouped_lat_lon   = GROUP user_rounded_lat_lon BY (lat, lon);
lat_lon_count     = FOREACH grouped_lat_lon GENERATE group.lat, group.lon, COUNT(user_rounded_lat_lon);
rmf $OUTPUT
STORE lat_lon_count INTO '$OUTPUT';
