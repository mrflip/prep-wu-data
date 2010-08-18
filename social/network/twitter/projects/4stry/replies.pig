-- params
%default BEGIN         '20060101000000' -- Jan 1st, 2006
%default END           '30000101000000' -- In the year 3000...
%default OBJECTS       '/data/sn/tw/fixd/objects'
	
-- load	
reply = LOAD '$OBJECTS/a_replies_b' AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long);

-- find user ids and hours for replies of $USER_B_ID
matching_reply            = FILTER reply BY user_b_id == (long) '$USER_B_ID' AND crat >= (long) '$BEGIN' AND crat < (long) '$END';
matching_crat_and_user_id = FOREACH matching_reply GENERATE crat, user_a_id AS user_id;
rmf                                  '$OUTPUT_DIR/replies' 
STORE matching_crat_and_user_id INTO '$OUTPUT_DIR/replies' ;

-- -- grouped by hour
-- grouped_by_hour = GROUP matching_hour_and_user_id BY hour;
-- count_by_hour   = FOREACH grouped_by_hour GENERATE group AS hour, COUNT(matching_hour_and_user_id) AS num;
-- rmf                       $OUTPUT_DIR/replies_by_hour
-- STORE count_by_hour INTO '$OUTPUT_DIR/replies_by_hour';

-- -- grouped by user
-- grouped_by_user = GROUP matching_hour_and_user_id BY user_id;
-- count_by_user   = FOREACH grouped_by_user GENERATE group AS user_id, COUNT(matching_hour_and_user_id) AS num;
-- rmf                       $OUTPUT_DIR/replies_by_user
-- STORE count_by_user INTO '$OUTPUT_DIR/replies_by_user';
