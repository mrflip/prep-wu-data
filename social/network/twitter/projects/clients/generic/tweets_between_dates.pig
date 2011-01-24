--
-- Given a begin and end date, returns only those tweets between them
--
tweet = LOAD '$TWEET' AS (rsrc:chararray, tweet_id:long, created_at:long, user_id:long, screen_name:chararray, search_id:long, in_reply_to_user_id:long, in_reply_to_screen_name:chararray, in_reply_to_search_id:long, in_reply_to_status_id:long, text:chararray, source:chararray, lang:chararray, lat:float, lng:float, retweeted_count:int, rt_of_user_id:long, rt_of_screen_name:chararray, rt_of_tweet_id:long, contributors:chararray);
range = FILTER tweet BY (created_at > $BEGIN) AND (created_at < $END);
rmf $OUT;
STORE range INTO '$OUT';
