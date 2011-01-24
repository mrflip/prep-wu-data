tweet = LOAD '$TWEET' AS (rsrc:chararray, twid:long, crat:long, user_id:long,    sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
ids   = LOAD '$UID'   AS (user_id:long);        

select_tweets = JOIN tweet BY user_id, ids BY user_id USING 'replicated';
STORE select_tweets INTO '$TWEET_SAMPLE';
