-- params
%default BEGIN         '20060101000000' -- Jan 1st, 2006
%default END           '30000101000000' -- In the year 3000...
%default OBJECTS       '/data/sn/tw/fixd/objects'	

-- load	
tweet = LOAD '$OBJECTS/tweet-merged' AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);

-- filter
matching_tweet = FILTER tweet BY uid == (long) '$USER_ID' AND crat >= (long) '$BEGIN' AND crat < (long) '$END' ;
rmf                      $OUTPUT_DIR/tweets
STORE matching_tweet INTO '$OUTPUT_DIR/tweets';
