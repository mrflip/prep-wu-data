SELECT username, twitter_id, pagerank_raw, pagerank_scaled, followers, following, tweets, joined_at  FROM tweeters 
INTO OUTFILE '/tmp/trstrank_scaled.tsv' 
FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n';


-- Want to convert the data from the above dump to JSON for API using the same keys as the data from Twitter. (see below)

-- User data from twitter:
-- {"statuses_count":1,
  -- "profile_background_tile":false,
  -- "profile_link_color":"2FC2EF",
  -- "description":null,
  -- "lang":"en",
  -- "favourites_count":0,
  -- "status":{"coordinates":null,
  -- "in_reply_to_user_id":null,
  -- "geo":null,
  -- "created_at":"Sat Jan 17 22:40:19 +0000 2009",
  -- "source":"web",
  -- "in_reply_to_screen_name":null,
  -- "place":null,
  -- "favorited":false,
  -- "truncated":false,
  -- "contributors":null,
  -- "in_reply_to_status_id":null,
  -- "id":1127018618,
  -- "text":"happily staring at a autograph of a fav singer"},
  -- "contributors_enabled":false,
  -- "notifications":false,
  -- "created_at":"Sat Jan 17 22:38:26 +0000 2009",
  -- "profile_sidebar_fill_color":"252429",
  -- "geo_enabled":false,
  -- "following":false,
  -- "profile_sidebar_border_color":"181A1E",
  -- "profile_image_url":"http://s.twimg.com/a/1273620457/images/default_profile_3_normal.png",
  -- "verified":false,
  -- "url":null,
  -- "time_zone":null,
  -- "screen_name":"Breathless_18",
  -- "profile_background_color":"1A1B1F",
  -- "protected":false,
  -- "location":null,
  -- "followers_count":0,
  -- "name":"Gabrielle G",
  -- "profile_background_image_url":"http://s.twimg.com/a/1273620457/images/themes/theme9/bg.gif",
  -- "profile_text_color":"666666",
  -- "id":19126698,
  -- "utc_offset":null,
  -- "friends_count":0}
