
-- Generates a consistent sample

%default TW_DIR      '/data/sn/tw/fixd/objects'
%default SAMPLE_DIR  '/data/sn/tw/fixd/sample'
%default INV_SAMPLE_FRACTION '1000L'

--    77822764 2010-07-12 11:51 /data/sn/tw/fixd/objects/twitter_user_id/part-00000
--
--   903670606 2010-07-13 19:42 /data/sn/tw/fixd/objects/a_atsigns_b/part-r-00000
--  2497956040 2010-07-05 23:19 /data/sn/tw/fixd/objects/a_follows_b/part-00000
--     8171346 2010-07-13 16:53 /data/sn/tw/fixd/objects/a_replies_b/part-00000
--   243811125 2010-07-13 19:57 /data/sn/tw/fixd/objects/a_retweets_b/part-r-00000
--
--     3443390 2010-07-05 22:37 /data/sn/tw/fixd/objects/a_favorites_b/part-00000
--        1244 2010-07-07 21:56 /data/sn/tw/fixd/objects/bad_record/part-00000
--    11135635 2010-07-05 23:55 /data/sn/tw/fixd/objects/delete_tweet/part-00000
--     9191047 2010-07-05 23:58 /data/sn/tw/fixd/objects/geo/part-00000
--     4228507 2010-07-13 16:53 /data/sn/tw/fixd/objects/hashtag/part-00000
--     2330100 2010-07-13 16:53 /data/sn/tw/fixd/objects/smiley/part-00000
--       55150 2010-07-13 16:53 /data/sn/tw/fixd/objects/stock_token/part-00000
--   254385468 2010-07-08 19:34 /data/sn/tw/fixd/objects/tweet-no-reply-id/part-r-00000
--  9041535763 2010-07-08 21:23 /data/sn/tw/fixd/objects/tweet/part-00000
--    11297117 2010-07-13 16:53 /data/sn/tw/fixd/objects/tweet_url/part-00000
--    66139312 2010-07-07 17:28 /data/sn/tw/fixd/objects/twitter_user/part-00000
--    56613923 2010-07-07 20:26 /data/sn/tw/fixd/objects/twitter_user_location/part-00000
--     3543195 2010-07-07 21:52 /data/sn/tw/fixd/objects/twitter_user_partial/part-00000
--   112151330 2010-07-07 20:59 /data/sn/tw/fixd/objects/twitter_user_profile/part-00000
--    27642888 2010-07-07 21:38 /data/sn/tw/fixd/objects/twitter_user_search_id/part-00000
--   197940250 2010-07-07 21:30 /data/sn/tw/fixd/objects/twitter_user_style/part-00000


twitter_user_id  = LOAD '$TW_DIR/twitter_user_id/' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:long, friends_count:long, statuses_count:long, favourites_count:long, created_at:long, sid:long, is_full:long, health:chararray);
a_follows_b      = LOAD '$TW_DIR/a_follows_b/'     AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_replies_b      = LOAD '$TW_DIR/a_replies_b/'     AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long, in_reply_to_tweet_id:long);
a_atsigns_b      = LOAD '$TW_DIR/a_atsigns_b/'   AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long);
a_retweets_b     = LOAD '$TW_DIR/a_retweets_b/'  AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long, please_flag:int);

twitter_user_id_s = FILTER twitter_user_id BY (user_id % (long)$INV_SAMPLE_FRACTION == 31L);
rmf                           $SAMPLE_DIR/twitter_user_id    
STORE twitter_user_id_s INTO '$SAMPLE_DIR/twitter_user_id';

a_follows_b_s     = FILTER a_follows_b BY (user_a_id % (long)$INV_SAMPLE_FRACTION == 31L);
rmf                           $SAMPLE_DIR/a_follows_b    
STORE a_follows_b_s     INTO '$SAMPLE_DIR/a_follows_b';

a_replies_b_s     = FILTER a_replies_b BY (user_a_id % (long)$INV_SAMPLE_FRACTION == 31L);
rmf                           $SAMPLE_DIR/a_replies_b    
STORE a_replies_b_s     INTO '$SAMPLE_DIR/a_replies_b';

a_atsigns_b_s     = FILTER a_atsigns_b BY (user_a_id % (long)$INV_SAMPLE_FRACTION == 31L);
rmf                           $SAMPLE_DIR/a_atsigns_b    
STORE a_atsigns_b_s     INTO '$SAMPLE_DIR/a_atsigns_b';

a_retweets_b_s     = FILTER a_retweets_b BY (user_a_id % (long)$INV_SAMPLE_FRACTION == 31L);
rmf                           $SAMPLE_DIR/a_retweets_b    
STORE a_retweets_b_s     INTO '$SAMPLE_DIR/a_retweets_b';

