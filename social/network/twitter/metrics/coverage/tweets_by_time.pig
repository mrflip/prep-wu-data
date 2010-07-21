%default TWEET         '/data/sn/tw/fixd/objects/tweet'
%defautl TWCOUNT       '/data/sn/tw/scrape_stats/tweet_counts'
        
tweet      = LOAD '$TWEET'         AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
cut_tweet = FOREACH tweet GENERATE (crat / 1000000) AS yearmonthday;
grouped   = GROUP cut_tweet BY yearmonthday;
counts    = FOREACH grouped GENERATE group AS timestamp, COUNT(cut_tweet) AS num_tweets;

rmf $TWCOUNT;
STORE counts INTO '$TWCOUNT';
