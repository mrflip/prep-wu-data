%default BEGIN_DATE 20060101000000L -- Jan 1st, 2006
%default END_DATE   30000101000000L -- In the year 3000...
%default USER_ID    12345L        
%default AT   's3:s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/objects/a_atsigns_b'
	
a_atsigns_b   = LOAD '$AT' AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long);
a_atsigns_b_f = FILTER a_atsigns_b BY user_b_id == $USER_ID AND crat >= $BEGIN_DATE AND crat < $END_DATE;
a_atsigns_b_c = FOREACH a_atsigns_b_f GENERATE crat, user_a_id AS user_id;

STORE a_atsigns_b_c INTO '$MATCHING_ATSIGNS';
