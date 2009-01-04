
LOAD DATA INFILE '20081222-sorted-uff/a_atsigns_b.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`a_atsigns_bs`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'a_atsigns_b\t'
  (@dummy, scraped_at,user_a_id,user_b_name)
  ;
SELECT 'a_atsigns_b', NOW(), COUNT(*) FROM `a_atsigns_bs`;


LOAD DATA INFILE '20081222-sorted-uff/a_replied_b.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`a_replied_bs`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'a_replied_b\t'
  (@dummy, scraped_at,user_a_id,user_b_id,status_id)
  ;
SELECT 'a_replied_b', NOW(), COUNT(*) FROM `a_replied_bs`;


LOAD DATA INFILE '20081222-sorted-uff/hashtag.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`hashtags`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'hashtag\t'
  (@dummy, scraped_at,user_a_id,hashtag)
  ;
SELECT 'hashtag', NOW(), COUNT(*) FROM `hashtags`;


LOAD DATA INFILE '20081222-sorted-uff/tweet_url.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`tweet_urls`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'tweet_url\t'
  (@dummy, scraped_at,user_a_id,tweet_url)
  ;
SELECT 'tweet_url', NOW(), COUNT(*) FROM `tweet_urls`;


LOAD DATA INFILE '20081222-sorted-uff/twitter_user_profile.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`twitter_user_profiles`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'twitter_user_profile\t'
  (@dummy, twitter_user_id,id,name,url,location,description,time_zone)
  ;
SELECT 'twitter_user_profile', NOW(), COUNT(*) FROM `twitter_user_profiles`;


LOAD DATA INFILE '20081222-sorted-uff/twitter_user_style.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`twitter_user_styles`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'twitter_user_style\t'
  (@dummy, twitter_user_id,id,profile_background_color,profile_text_color,profile_link_color,profile_sidebar_border_color,profile_sidebar_fill_color,profile_background_image_url,profile_image_url)
  ;
SELECT 'twitter_user_style', NOW(), COUNT(*) FROM `twitter_user_styles`;


LOAD DATA INFILE '20081222-sorted-uff/twitter_user.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`twitter_users`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'twitter_user\t'
  (@dummy, scraped_at,id,screen_name,created_at,statuses_count,followers_count,friends_count,favourites_count,scraped_at)
  ;
SELECT 'twitter_user', NOW(), COUNT(*) FROM `twitter_users`;


LOAD DATA INFILE '20081222-sorted-uff/twitter_user_partial.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`twitter_user_partials`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'twitter_user_partial\t'
  (@dummy, scraped_at,id,screen_name,followers_count,protected,name,url,location,description,scraped_at)
  ;
SELECT 'twitter_user_partial', NOW(), COUNT(*) FROM `twitter_user_partials`;


LOAD DATA INFILE '20081222-sorted-uff/tweet.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`tweets`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'tweet\t'
  (@dummy, scraped_at,id,created_at,twitter_user_id,text,favorited,truncated,tweet_len,in_reply_to_user_id,in_reply_to_status_id,fromsource)
  ;
SELECT 'tweet', NOW(), COUNT(*) FROM `tweets`;


LOAD DATA INFILE '20081222-sorted-uff/a_follows_b.tsv'
  REPLACE INTO TABLE        `imw_twitter_graph`.`a_follows_bs`
  COLUMNS
    TERMINATED BY           '\t'
    OPTIONALLY ENCLOSED BY  '"'
    ESCAPED BY              ''
  LINES STARTING BY         'a_follows_b\t'
  (@dummy, scraped_at,user_a_id)
  ;
SELECT 'a_follows_b', NOW(), COUNT(*) FROM `a_follows_bs`;
  
