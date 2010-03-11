-- defaults
%default OUTPUT '/data/fixd/social/network/myspace/users_by_zip'           ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- load user data
full_user     = LOAD '$USER' AS (rsrc:chararray, person_id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;

-- filter by a well-formed lat/long pair
user 	      = FOREACH full_user GENERATE lat, lon;
user_lat_lon  = FILTER user BY lat MATCHES '(+|-)?[0-9.]+' AND lon MATCHES '(+|-)?[0-9.]+';
grouped_lat_lon   = GROUP user_lat_lon BY org.apache.pig.piggybank.evaluation.math.ROUND(lat * 10.0) / 10.0 AS lat, org.apache.pig.piggybank.evaluation.math.ROUND(lon * 10.0) / 10.0 AS lon
lat_lon_count     = FOREACH grouped_lat_lon GENERATE lat, lon, COUNT(user_lat_lon);
rmf $OUTPUT
STORE zip_count INTO '$OUTPUT';
