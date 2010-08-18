-- usage: pig -p BEGIN=20060101000000L -p END=30000101000000L -p ATS=/data/sn/tw/fixd/objects/a_atsigns_b -p USERID=14598992L -p OUTPUT_DIR=/tmp atsigns.pig
%default BEGIN 20060101000000 -- Jan 1st, 2006
%default END   30000101000000 -- In the year 3000...
%default ATS   's3:s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/objects/a_atsigns_b'
	
-- load	
atsign = LOAD '$ATS' AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long);

-- find user ids and hours for atsigns of $USER_B_ID
matching_atsign           = FILTER atsign BY user_b_id == (long) '$USER_B_ID' AND crat >= (long) '$BEGIN' AND crat < (long) '$END';
matching_crat_and_user_id = FOREACH matching_atsign GENERATE crat, user_a_id AS user_id;
rmf                                   $OUTPUT_DIR/atsigns
STORE matching_crat_and_user_id	INTO '$OUTPUT_DIR/atsigns' ;
