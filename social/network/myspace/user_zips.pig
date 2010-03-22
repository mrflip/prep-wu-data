-- defaults
%default OUTPUT '/data/fixd/social/network/myspace/users_by_zip'           ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

full_user     = LOAD '$USER' AS (rsrc:chararray, id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;
user 	      = FOREACH full_user GENERATE id, zip_code;
user_group    = GROUP user BY id;
distinct_user_all_zips = FOREACH user_group GENERATE group AS id, FLATTEN(user.zip_code);
distinct_user = FOREACH distinct_user_all_zips GENERATE $0, $1;
distinct_user_with_zip = FILTER distinct_user BY zip_code MATCHES '[0-9]{5}(-[0-9]{4})?';
grouped_zip   = GROUP distinct_user_with_zip BY zip_code;
zip_count     = FOREACH grouped_zip GENERATE group AS zip_code, COUNT(distinct_user_with_zip);
rmf $OUTPUT
STORE zip_count INTO '$OUTPUT';
