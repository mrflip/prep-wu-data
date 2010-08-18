-- usage: pig -p BEGIN=20060101000000L -p END=30000101000000L -p ATS=/data/sn/tw/fixd/objects/a_atsigns_b -p USERID=14598992L -p OUTPUT_DIR=/tmp atsigns.pig
%default BEGIN 20060101000000 -- Jan 1st, 2006
%default END   30000101000000 -- In the year 3000...
%default ATS   's3:s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/objects/a_atsigns_b'

-- pull out mentions of USERID in specifiend time window
a_atsigns_b    = LOAD '$ATS' AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long);
a_atsigns_b_f  = FILTER a_atsigns_b BY user_b_id == $USERID AND crat >= $BEGIN AND crat < $END;
a_atsigns_b_fg = FOREACH a_atsigns_b_f GENERATE crat / 10000 AS hour, user_a_id AS user_id;

-- get mention counts as a function of hour
mentions_by_hr   = GROUP a_atsigns_b_fg BY hour;
mentions_by_hr_c = FOREACH mentions_by_hr GENERATE group AS hour, COUNT(a_atsigns_b_fg) AS num;
STORE mentions_by_hr_c INTO '$OUTPUT_DIR/atsigns_by_hour';

-- get mentions counts as a function of user_id
mentions_by_usr   = GROUP a_atsigns_b_fg BY user_id;
mentions_by_usr_c = FOREACH mentions_by_usr GENERATE group AS user_id, COUNT(a_atsigns_b_fg) AS num;
STORE mentions_by_usr_c INTO '$OUTPUT_DIR/atsigns_by_user';
