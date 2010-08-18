-- usage: pig -p BEGIN=20060101000000L -p END=30000101000000L -p RT=/data/sn/tw/fixd/objects/a_retweets_b -p USERID=14598992L -p OUTPUT_DIR=/tmp retweets.pig
%default BEGIN 20060101000000 -- Jan 1st, 2006
%default END   30000101000000 -- In the year 3000...
%default RT    's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/objects/a_retweets_b'

-- pull out mentions of USERID in specifiend time window        
a_retweets_b    = LOAD '$RT' AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long, plz_flag:int);
a_retweets_b_f  = FILTER a_retweets_b BY user_b_id == $USERID AND crat >= $BEGIN AND crat < $END;
a_retweets_b_fg = FOREACH a_retweets_b_f GENERATE crat / 10000 AS hour, user_a_id AS user_id;

-- get mention counts as a function of hour
retweets_by_hr   = GROUP a_retweets_b_fg BY hour;
retweets_by_hr_c = FOREACH retweets_by_hr GENERATE group AS hour, COUNT(a_retweets_b_fg) AS num;
STORE retweets_by_hr_c INTO '$OUTPUT_DIR/retweets_by_hour';

-- get retweets counts as a function of user_id
retweets_by_usr   = GROUP a_retweets_b_fg BY user_id;
retweets_by_usr_c = FOREACH retweets_by_usr GENERATE group AS user_id, COUNT(a_retweets_b_fg) AS num;
STORE retweets_by_usr_c INTO '$OUTPUT_DIR/retweets_by_user';
