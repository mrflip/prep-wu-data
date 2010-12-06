--
-- Given a begin and end date, returns only those tweets between them with a tweet total count
--

--
-- Usage: PIG_OPTS='-Dmapred.reduce.tasks=X' pig -p TWEET=/path/to/tweets -p BEGIN=20100801000000L -p END=20101119000000L -p OUT=/path/to/output tweets_between_dates.pig
--

tweet          = LOAD '$TWEET' AS (rsrc:chararray, tweet_id:long, created_at:long, user_id:long, screen_name:chararray, search_id:long, in_reply_to_user_id:long, in_reply_to_screen_name:chararray, in_reply_to_search_id:long, in_reply_to_status_id:long, text:chararray, source:chararray, lang:chararray, lat:float, lng:float, retweeted_count:int, rt_of_user_id:long, rt_of_screen_name:chararray, rt_of_tweet_id:long, contributors:chararray);
cut_tweet      = FOREACH tweet GENERATE created_at;
range          = FILTER cut_tweet BY (created_at > $BEGIN) AND (created_at < $END);
tweet_by_date  = GROUP range BY created_at;
info_out       = FOREACH tweet_by_date GENERATE group AS created_at, COUNT(range) AS num_tweets;

STORE info_out INTO '$OUT';
