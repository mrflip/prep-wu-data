%default ATS 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/20100806/a_atsigns_b'
%default TWT 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/20100806/tweet-merged'
%default UID '14128468L'

tweet   = LOAD '$TWT' AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float);
tweet_f = FILTER tweet BY uid == $UID;
STORE tweet_f INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/client/buster_keaton_tweet';

a_atsigns_b   = LOAD '$ATS' AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    crat:long);
a_atsigns_b_f = FILTER a_atsigns_b BY user_b_id == $UID;
STORE a_atsigns_b_f INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/client/buster_keaton_mentions';
