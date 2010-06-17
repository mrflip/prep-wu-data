-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults, the path to tweets is different on the clusta
%default TWEET   '/data/soc/net/tw/fixd/objects/tweet' ;

full_tweet = LOAD '$TWEET' AS (rsrc:chararray, id:long, created_at:long, user_id:long, favorited:int, truncated:int, reply_to_user_id:long, reply_to_status_id:long, text:chararray, source:chararray, reply_to_screen_name:chararray) ;
tweet = FOREACH full_tweet GENERATE user_id, text;
matched_tweet = FILTER tweet
  BY      org.apache.pig.piggybank.evaluation.string.UPPER(text)
  MATCHES '$REGEXP' ;
grouped_matched_tweet = GROUP matched_tweet BY user_id;
tweet_count   = FOREACH grouped_matched_tweet GENERATE group AS user_id, matched_tweet.text, COUNT(matched_tweet);
STORE tweet_count INTO '$OUTPUT';
