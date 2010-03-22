/*

Find all tweets from a given user (regexp):

$ pig -p REGEXP=NYTIMES -p OUTPUT=/data/anal/social/network/twitter/nytimes_tweets

Output tweet schema is

  created_at, favorited, truncated, reply_to_user_id, reply_to_status_id, text, source, reply_to_screen_name

*/

-- for UPPER function below	
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- default paths
%default TWEET   '/data/fixd/tw/out/tweet' ;
%default USER    '/data/fixd/tw/models/twitter_user' ;

-- load data
tweet = LOAD '$TWEET' AS (rsrc:chararray, id:long, created_at:long, user_id:long, favorited:int, truncated:int, reply_to_user_id:long, reply_to_status_id:long, text:chararray, source:chararray, reply_to_screen_name:chararray) ;                      -- (tweet,56,20060321224142,21,0,0,,,twttr my nttr,web,)
user = LOAD '$USER' AS (rsrc:chararray, id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:int, friends_count:int, statuses_count:int, favorites_count:int, created_at:long);

-- find matching users' tweets
matching_user = FILTER user BY org.apache.pig.piggybank.evaluation.string.UPPER(screen_name) MATCHES '$REGEXP';
matching_user_id = FOREACH matching_user GENERATE id AS user_id;
matching_user_tweet = JOIN matching_user_id BY user_id, tweet BY user_id;
matching_tweet = FOREACH matching_user_tweet GENERATE created_at, favorited, truncated, reply_to_user_id, reply_to_status_id, text, source, reply_to_screen_name;
rmf $OUTPUT
STORE matching_tweet INTO '$OUTPUT';