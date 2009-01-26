REGISTER /public/share/pig/contrib/piggybank/java/piggybank.jar ;

Tweets17to24            = FILTER Tweets BY (created_at > 20090117000000L) AND (created_at < 20090124235959L) PARALLEL 50;
-- STORE Tweets17to24      INTO 'meta/inaug/tweets_17to24' ;
Tweets17to24            = LOAD 'meta/inaug/tweets_17to24' AS (rsrc: chararray, tw_id: int,   created_at: long, user_id: int, favorited: int, truncated: int, repl_user_id: int, repl_tw_id: int, text: chararray, src: chararray );

--
-- Extract tweets matching keyword
-- 
InaugTweets             = FILTER Tweets17to24 BY org.apache.pig.piggybank.evaluation.string.UPPER(text) MATCHES '.*(INAUG|OBAMA|BIDEN|CHENEY|BUSH).*' ;
-- STORE InaugTweets         INTO 'meta/inaug/inaug_tweets' ;
InaugTweets             = LOAD 'meta/inaug/inaug_tweets' AS (rsrc: chararray, tw_id: int,   created_at: long, user_id: int, favorited: int, truncated: int, repl_user_id: int, repl_tw_id: int, text: chararray, src: chararray );

--
-- Get just the user_ids of those twitters
-- 
InaugUserIDs_0          = FOREACH InaugTweets GENERATE user_id ;
InaugUserIDs            = DISTINCT InaugUserIDs_0 PARALLEL 10 ;
-- STORE InaugUserIDs        INTO 'meta/inaug/inaug_user_ids' ;
InaugUserIDs            = LOAD 'meta/inaug/inaug_user_ids' AS (user_id: int );

--
-- Get the Users, Profiles and Styles for each
--
InaugUsers_1            = JOIN InaugUserIDs BY user_id, Users BY user_id PARALLEL 10;
InaugUsers              = FOREACH InaugUsers_1 GENERATE Users::rsrc, Users::user_id AS user_id, scraped_at, screen_name, protected, followers_count, friends_count, statuses_count, favorites_count, created_at ;
-- STORE InaugUsers          INTO 'meta/inaug/inaug_users' ;
InaugUsers              = LOAD 'meta/inaug/inaug_users'         AS (rsrc: chararray, user_id: int, scraped_at: long, screen_name: chararray, protected: int, followers_count: int, friends_count: int, statuses_count: int, favorites_count: int, created_at: long);

InaugUserProfs_1        = JOIN InaugUserIDs BY user_id, UserProfiles BY user_id PARALLEL 10;
InaugUserProfs          = FOREACH InaugUserProfs_1 GENERATE UserProfiles::rsrc, UserProfiles::user_id, scraped_at, full_name, url, location, description, time_zone, utc_offset;
-- STORE InaugUserProfs      INTO 'meta/inaug/inaug_user_profs' ;
InaugUserProfs          = LOAD 'meta/inaug/inaug_user_profs'    AS (rsrc: chararray, user_id: int, scraped_at: long, full_name:   chararray, url: chararray, location: chararray, description: chararray, time_zone: chararray, utc_offset: int); 

InaugUserStyles_1       = JOIN InaugUserIDs BY user_id, UserStyles BY user_id PARALLEL 10;
InaugUserStyles         = FOREACH InaugUserStyles_1 GENERATE UserStyles::rsrc, UserStyles::user_id, scraped_at, profile_background_color, profile_text_color, profile_link_color, profile_sidebar_border_color, profile_sidebar_fill_color, profile_background_tile, profile_background_image_url, profile_image_url;
STORE InaugUserStyles     INTO 'meta/inaug/inaug_user_styles' ;
InaugUserStyles         = LOAD 'meta/inaug/inaug_user_styles'   AS  (rsrc: chararray, user_id: int, scraped_at: long, profile_background_color: chararray, profile_text_color: chararray, profile_link_color: chararray, profile_sidebar_border_color: chararray, profile_sidebar_fill_color: chararray, profile_background_tile: int, profile_background_image_url: chararray, profile_image_url: chararray);


-- meta/inaug/tweets_17to24       424175474
-- meta/inaug/inaug_tweets          7282621
-- meta/inaug/inaug_user_ids        3881238
-- meta/inaug/inaug_user_profs     50480487
-- meta/inaug/inaug_user_styles    69307877
-- meta/inaug/inaug_users          22500868


