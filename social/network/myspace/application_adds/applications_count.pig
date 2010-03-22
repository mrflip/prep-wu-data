-- defaults
%default APPADD       '/data/fixd/social/network/myspace/objects/application_add' ;
%default OUTPUT_DIR   '/data/fixd/social/network/myspace/application_adds'        ;
%default OUTPUT       '$OUTPUT_DIR/application_add_count'                         ;

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- get status update
full_app = LOAD '$APPADD' AS (rsrc:chararray, created_at:long, activity_id:long, user_id:long, text:chararray, category:chararray, app_name:chararray, object_author:chararray, target_title:chararray, source:chararray) ;
app = FOREACH full_app GENERATE app_name;
app_group = GROUP app BY app_name;
app_count = FOREACH app_group GENERATE group, COUNT(app);
rmf $OUTPUT
STORE app_count INTO '$OUTPUT';
