-- defaults
%default OUTPUT '/data/fixd/social/network/myspace/users_by_zip'           ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- load user data
full_user     = LOAD '$USER' AS (rsrc:chararray, person_id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;

-- filter by a well-formed ZIP code
user 	      = FOREACH full_user GENERATE zip_code;
user_with_zip = FILTER user BY zip_code MATCHES '[0-9]{5}(-[0-9]{4})?';
grouped_zip   = GROUP user_with_zip BY zip_code;
zip_count     = FOREACH grouped_zip GENERATE group AS zip_code, COUNT(user_with_zip);
rmf $OUTPUT
STORE zip_count INTO '$OUTPUT';
