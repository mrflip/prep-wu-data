--
-- UDF Stores
--
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

--
-- Twitter Model classes
--

AFollowsB           = LOAD 'fixd/tw/out/a_follows_b'                 AS (rsrc: chararray, user_a_id: long, user_b_id: long);
ARetweetsB_N        = LOAD 'fixd/tw/out/a_retweets_b'                AS (rsrc: chararray, user_a_id: long, user_b_name: chararray,    tw_id: long, pls_flag:long, text:chararray);
AAtsignsB_N         = LOAD 'fixd/tw/out/a_atsigns_b'                 AS (rsrc: chararray, user_a_id: long, user_b_name: chararray,    tw_id: long);
ARepliesB           = LOAD 'fixd/tw/out/a_replies_b'                 AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long, reply_tw_id:long);
AFavoritesB         = LOAD 'fixd/tw/out/a_favorites_b'               AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long);

TweetUrl            = LOAD 'fixd/tw/out/tweet_url'                   AS (rsrc: chararray, url: chararray, tw_id: long, user_id: long);
HashTag             = LOAD 'fixd/tw/out/hashtag'                     AS (rsrc: chararray, url: chararray, tw_id: long, user_id: long);

TwitterUser         = LOAD 'fixd/tw/out/twitter_user'                AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long, friends_count: long, statuses_count: long, favorites_count: long, created_at: long);
TwitterUserPartial  = LOAD 'fixd/tw/out/twitter_user_partial'        AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long,
                                                                                                                         full_name:   chararray, url: chararray, location: chararray, description: chararray, profile_image_url:chararray);
TwitterUserProfile  = LOAD 'fixd/tw/out/twitter_user_profile'        AS (rsrc: chararray, user_id: long, scraped_at: long, full_name:   chararray, url: chararray, location: chararray, description: chararray, time_zone: chararray, utc_offset: long);
TwitterUserStyle    = LOAD 'fixd/tw/out/twitter_user_style'          AS (rsrc: chararray, user_id: long, scraped_at: long, profile_background_color: chararray, profile_text_color: chararray, profile_link_color: chararray, profile_sidebar_border_color: chararray, profile_sidebar_fill_color: chararray, profile_background_tile: long, profile_background_image_url: chararray, profile_image_url: chararray);

Tweet               = LOAD 'fixd/tw/out/tweet'                       AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray );

-- Scrape		    = LOAD ''

Tokens = LOAD 'tmp/sampled_toks' AS (
  rsrc:                 chararray,
  text:                 chararray,
  tweet_id:             long,
  twitter_user_id:      chararray, -- right now search_tweet tokens come out with username only
  created_at:           long
  );
