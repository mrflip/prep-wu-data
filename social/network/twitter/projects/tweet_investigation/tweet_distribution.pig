--
-- Distribution of tweets count
--
tweet     = LOAD '$TWEET' AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, text:chararray, src:chararray, lang:chararray, lat:float, lon:float, stuff:chararray);
cut_tweet = FOREACH tweet GENERATE uid AS user_id, twid AS tweet_id;
grpd      = GROUP cut_tweet BY user_id PARALLEL $REDUCES;
counts    = FOREACH grpd GENERATE group AS user_id, COUNT(cut_tweet) AS num_tweets;
ordrd     = ORDER counts BY num_tweets DESC PARALLEL $REDUCES;

STORE ordrd INTO '$HDFS/$OUT';
