-- defaults
%default APPADD       '/data/fixd/social/network/myspace/objects/application_add' ;
%default OUTPUT_DIR   '/data/fixd/social/network/myspace/application_adds'        ;
%default OUTPUT       '$OUTPUT_DIR/application_add_by_day'                        ;

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- get status update
full_add = LOAD '$APPADD' AS (rsrc:chararray, created_at:chararray, activity_id:long, user_id:long, text:chararray, category:chararray, app_name:chararray, object_author:chararray, target_title:chararray, source:chararray) ;
app = FOREACH full_add GENERATE org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 8) AS created_at, app_name;
app_group = GROUP app BY (created_at, app_name);
app_count = FOREACH app_group GENERATE group.created_at, group.app_name, COUNT(app);
rmf $OUTPUT
STORE app_count INTO '$OUTPUT';


