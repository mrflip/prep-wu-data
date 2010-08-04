%default TWEET               '/data/sn/tw/fixd/objects/tweet'
%default INV_SAMPLE_FRACTION 10000
%default SAMPLE_SEED         1	

tweet = LOAD '$TWEET'         AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);

tweet_s = FILTER tweet BY (twid % (long) $INV_SAMPLE_FRACTION == (long) $SAMPLE_SEED);
rmf $OUTPUT
STORE tweet_s INTO '$OUTPUT';
