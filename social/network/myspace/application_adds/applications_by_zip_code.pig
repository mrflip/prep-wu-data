-- defaults
%default APPADD       '/data/fixd/social/network/myspace/objects/application_add' ;
%default USER         '/data/fixd/social/network/myspace/objects/myspace_person'  ;
%default OUTPUT_DIR   '/data/fixd/social/network/myspace/application_adds'        ;
%default OUTPUT       '$OUTPUT_DIR/application_add_by_zip'                        ;

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- get status update
full_app = LOAD '$APPADD' AS (rsrc:chararray, created_at:long, activity_id:long, user_id:long, text:chararray, category:chararray, app_name:chararray, object_author:chararray, target_title:chararray, source:chararray) ;
app = FOREACH full_app GENERATE user_id, app_name;

-- get user
full_user = LOAD '$USER' AS (rsrc:chararray, id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;
user = FOREACH full_user GENERATE id, zip_code ;
user_group    = GROUP user BY id;
distinct_user_all_zips = FOREACH user_group GENERATE group AS id, FLATTEN(user.zip_code);
distinct_user = FOREACH distinct_user_all_zips GENERATE $0, $1;
distinct_user_with_zip = FILTER distinct_user BY zip_code MATCHES '[0-9]{5}(-[0-9]{4})?';

app_user = JOIN app BY user_id, distinct_user_with_zip BY id;
app_zip = FOREACH app_user GENERATE app::app_name AS app_name, distinct_user_with_zip::zip_code AS zip_code;
app_zip_group = GROUP app_zip BY (zip_code, app_name);
app_zip_count = FOREACH app_zip_group GENERATE group.zip_code, group.app_name, COUNT(app_zip);
rmf $OUTPUT
STORE app_zip_count INTO '$OUTPUT';
