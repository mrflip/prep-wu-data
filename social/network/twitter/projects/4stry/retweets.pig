%default BEGIN_DATE 20060101000000L -- Jan 1st, 2006
%default END_DATE   30000101000000L -- In the year 3000...
%default USER_ID    12345L        
%default RT   's3:s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/objects/a_retweets_b'
	
a_retweets_b   = LOAD '$RT' AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long, plz_flag:int);
a_retweets_b_f = FILTER a_retweets_b BY user_b_id == $USER_ID AND crat >= $BEGIN_DATE AND crat < $END_DATE;
a_retweets_b_c = FOREACH a_retweets_b_f GENERATE crat, user_a_id AS user_id;

STORE a_retweets_b_c INTO '$MATCHING_RETWEETS';
