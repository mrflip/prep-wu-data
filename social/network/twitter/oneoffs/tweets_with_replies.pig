
%default TWROOT  '/data/rawd/social/network/twitter/objects'
%default TWWREPL '/data/rawd/social/network/twitter/oneoffs/tweets_with_replies'
%default STWWREPL '/data/rawd/social/network/twitter/oneoffs/search_tweets_with_replies'

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

TwitterUser = LOAD '$TWROOT/twitter_user' AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long, friends_count: long, statuses_count: long, favorites_count: long, created_at: long);
Tweet       = LOAD '$TWROOT/tweet'        AS (rsrc: chararray, tw_id: long,   created_at: chararray, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray );
SearchTweet = LOAD '$TWROOT/search_tweet' AS (rsrc: chararray, tw_id: long,   created_at: chararray, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_sid: long, twitter_user_screen_name: chararray, twitter_user_sid: long, iso_language_code: chararray);

-- TweetsWithReplies    = FILTER Tweet       BY (repl_tw_id IS NOT NULL) AND (repl_tw_id != 0L) AND (org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 6) == '201003');
-- rmf                           $TWWREPL
-- STORE TweetsWithReplies INTO '$TWWREPL';

SearchTweetsWithReplies = FILTER SearchTweet BY (in_reply_to_sid IS NOT NULL) AND (in_reply_to_sid != 0L) AND (org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 6) == '201003');
rmf                                 $STWWREPL
STORE SearchTweetsWithReplies INTO '$STWWREPL';
