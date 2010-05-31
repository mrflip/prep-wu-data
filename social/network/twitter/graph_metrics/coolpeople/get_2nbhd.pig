%default TWROOT  '/data/sn/tw/fixd/objects'
%default HOOD      '/data/sn/tw/cool/infochimps_hood'
%default HOODU     '/data/sn/tw/cool/infochimps_hood_u'
-- To avoid a huge # of tiny output files, and for downstream efficiency,
-- we sort jobs' outputs. These give the number of reducers to use for
-- files that are in general tiny (< 200MB), medium (< 2GB), or larger
%default PARALLEL_TINY  1
%default PARALLEL_MED   1
%default PARALLEL_LARGE 1

--
-- Target user set
--
n_ALL01             = LOAD '$HOOD/n_ALL01'                 AS (user_id: long);
screen_name_n01     = LOAD '$HOOD/screen_name_n01'         AS (screen_name: chararray);

-- --
-- -- Input data
-- --
-- AFollowsB           = LOAD '$TWROOT/a_follows_b'           AS (rsrc: chararray, user_a_id: long, user_b_id: long);
-- ARepliesB           = LOAD '$TWROOT/a_replies_b'           AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long, reply_tw_id:long);
-- TwitterUser         = LOAD '$TWROOT/twitter_user'          AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long, friends_count: long, statuses_count: long, favorites_count: long, created_at: long);
-- TwitterUserPartial  = LOAD '$TWROOT/twitter_user_partial'  AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long, full_name:   chararray, url: chararray, location: chararray, description: chararray, profile_image_url:chararray);
-- TwitterUserProfile  = LOAD '$TWROOT/twitter_user_profile'  AS (rsrc: chararray, user_id: long, scraped_at: long, full_name:   chararray, url: chararray, location: chararray, description: chararray, time_zone: chararray, utc_offset: long);
-- TwitterUserStyle    = LOAD '$TWROOT/twitter_user_style'    AS (rsrc: chararray, user_id: long, scraped_at: long, profile_background_color: chararray, profile_text_color: chararray, profile_link_color: chararray, profile_sidebar_border_color: chararray, profile_sidebar_fill_color: chararray, profile_background_tile: long, profile_background_image_url: chararray, profile_image_url: chararray);
-- Tweet               = LOAD '$TWROOT/tweet'                 AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray);
-- SearchTweet         = LOAD '$TWROOT/search_tweet'          AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_searchid: long, screen_name: chararray, user_searchid: long, iso_language_code: chararray);

-- ===========================================================================
--
-- Simple bjects in n0+n1
--

-- TwitterUser_n01_j        = JOIN    TwitterUser              BY user_id, n_ALL01 BY user_id using 'replicated';
-- TwitterUser_n01_f        = FOREACH TwitterUser_n01_j        GENERATE rsrc, TwitterUser::user_id,        scraped_at, screen_name, protected, followers_count, friends_count, statuses_count, favorites_count, created_at;
-- TwitterUserPartial_n01_j = JOIN    TwitterUserPartial       BY user_id, n_ALL01 BY user_id using 'replicated';
-- TwitterUserPartial_n01_f = FOREACH TwitterUserPartial_n01_j GENERATE rsrc, TwitterUserPartial::user_id, scraped_at, screen_name, protected, followers_count, full_name, url, location, description, profile_image_url;
-- TwitterUserProfile_n01_j = JOIN    TwitterUserProfile       BY user_id, n_ALL01 BY user_id using 'replicated';
-- TwitterUserProfile_n01_f = FOREACH TwitterUserProfile_n01_j GENERATE rsrc, TwitterUserProfile::user_id, scraped_at, full_name, url, location, description, time_zone, utc_offset;
-- TwitterUserStyle_n01_j   = JOIN    TwitterUserStyle         BY user_id, n_ALL01 BY user_id using 'replicated';
-- TwitterUserStyle_n01_f   = FOREACH TwitterUserStyle_n01_j   GENERATE rsrc, TwitterUserStyle::user_id,   scraped_at, profile_background_color, profile_text_color, profile_link_color, profile_sidebar_border_color, profile_sidebar_fill_color, profile_background_tile, profile_background_image_url, profile_image_url;
-- Tweet_n01_j              = JOIN Tweet                       BY user_id, n_ALL01 BY user_id using 'replicated';
-- Tweet_n01_f              = FOREACH Tweet_n01_j              GENERATE rsrc, tw_id, created_at, Tweet::user_id, favorited, truncated, repl_user_id, repl_tw_id, text, src;
-- SearchTweet_n01_j        = JOIN SearchTweet                 BY screen_name, screen_name_n01 BY screen_name using 'replicated';
-- SearchTweet_n01_f        = FOREACH SearchTweet_n01_j        GENERATE rsrc, tw_id, created_at, user_id, favorited, truncated, repl_user_id, repl_tw_id, text, src, in_reply_to_screen_name, in_reply_to_searchid, screen_name, twitter_user_searchid, iso_language_code;

AFollowsB_n01_f          = LOAD '$HOODU/a_follows_b_n01'           AS (rsrc: chararray, user_a_id: long, user_b_id: long);
ARepliesB_n01_f          = LOAD '$HOODU/a_replies_b_n01'           AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long, reply_tw_id:long);
TwitterUser_n01_f        = LOAD '$HOODU/twitter_user_n01'          AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long, friends_count: long, statuses_count: long, favorites_count: long, created_at: long);
TwitterUserPartial_n01_f = LOAD '$HOODU/twitter_user_partial_n01'  AS (rsrc: chararray, user_id: long, scraped_at: long, screen_name: chararray, protected: long, followers_count: long, full_name:   chararray, url: chararray, location: chararray, description: chararray, profile_image_url:chararray);
TwitterUserProfile_n01_f = LOAD '$HOODU/twitter_user_profile_n01'  AS (rsrc: chararray, user_id: long, scraped_at: long, full_name:   chararray, url: chararray, location: chararray, description: chararray, time_zone: chararray, utc_offset: long);
TwitterUserStyle_n01_f   = LOAD '$HOODU/twitter_user_style_n01'    AS (rsrc: chararray, user_id: long, scraped_at: long, profile_background_color: chararray, profile_text_color: chararray, profile_link_color: chararray, profile_sidebar_border_color: chararray, profile_sidebar_fill_color: chararray, profile_background_tile: long, profile_background_image_url: chararray, profile_image_url: chararray);
Tweet_n01_f              = LOAD '$HOODU/tweet_n01'                 AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray);
SearchTweet_n01_f        = LOAD '$HOODU/search_tweet_n01'          AS (rsrc: chararray, tw_id: long,   created_at: long, user_id: long, favorited: long, truncated: long, repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray, in_reply_to_screen_name: chararray, in_reply_to_searchid: long, screen_name: chararray, twitter_user_searchid: long, iso_language_code: chararray);

--
-- -- Sort and compact the results
--

TwitterUser_n01          = ORDER   TwitterUser_n01_f        BY user_id     PARALLEL $PARALLEL_TINY ;
TwitterUserPartial_n01   = ORDER   TwitterUserPartial_n01_f BY user_id     PARALLEL $PARALLEL_TINY ;
TwitterUserProfile_n01   = ORDER   TwitterUserProfile_n01_f BY user_id     PARALLEL $PARALLEL_TINY ;
TwitterUserStyle_n01     = ORDER   TwitterUserStyle_n01_f   BY user_id     PARALLEL $PARALLEL_TINY ;
-- Tweet Objects
Tweet_n01                = ORDER   Tweet_n01_f              BY user_id     PARALLEL $PARALLEL_MED  ;
SearchTweet_n01          = ORDER   SearchTweet_n01_f        BY screen_name PARALLEL $PARALLEL_MED  ;

-- ===========================================================================
--
-- Relationships in n0+n1
--

-- -- get followers and followees of user set
-- e_n01_FOi_j    = JOIN    AFollowsB     BY user_b_id, n_ALL01 BY user_id using 'replicated';
-- e_n01_FOi_f    = FOREACH e_n01_FOi_j   GENERATE rsrc, user_a_id, user_b_id ;
-- e_n01_FOo_j    = JOIN    AFollowsB     BY user_a_id, n_ALL01 BY user_id using 'replicated';
-- e_n01_FOo_f    = FOREACH e_n01_FOo_j   GENERATE rsrc, user_a_id, user_b_id ;
-- 
-- -- get atsigners and atsignees of user set
-- e_n01_REi_j    = JOIN    ARepliesB     BY user_b_id, n_ALL01 BY user_id using 'replicated';
-- e_n01_REi_f    = FOREACH e_n01_REi_j   GENERATE rsrc, user_a_id, user_b_id, tw_id, reply_tw_id;
-- e_n01_REo_j    = JOIN    ARepliesB     BY user_a_id, n_ALL01 BY user_id using 'replicated';
-- e_n01_REo_f    = FOREACH e_n01_REo_j   GENERATE rsrc, user_a_id, user_b_id, tw_id, reply_tw_id;

-- Load relationships
e_n01_FOi_f           = LOAD '$HOODU/e_n01_FOi'             AS (rsrc: chararray, user_a_id: long, user_b_id: long);
e_n01_FOo_f           = LOAD '$HOODU/e_n01_FOo'             AS (rsrc: chararray, user_a_id: long, user_b_id: long);
e_n01_REi_f           = LOAD '$HOODU/e_n01_REi'             AS (rsrc: chararray, user_a_id: long, user_b_id: long, tw_id: long, reply_tw_id:long);
e_n01_REo_f           = LOAD '$HOODU/e_n01_REo'             AS (rsrc: chararray, user_a_id: long, user_b_id: long, tw_id: long, reply_tw_id:long);

-- Sort and compact the relationship sets
e_n01_FOi                = ORDER   e_n01_FOi_f              BY user_a_id, user_b_id PARALLEL $PARALLEL_MED ;
e_n01_FOo                = ORDER   e_n01_FOo_f              BY user_a_id, user_b_id PARALLEL $PARALLEL_MED ;
e_n01_REi                = ORDER   e_n01_REi_f              BY user_a_id, user_b_id PARALLEL $PARALLEL_MED ;
e_n01_REo                = ORDER   e_n01_REo_f              BY user_a_id, user_b_id PARALLEL $PARALLEL_MED ;

-- ===========================================================================
--
-- Edge Sets in n0+n1
--

-- -- Make the combined edge neighborhood from the set union of the directed edge nbhds
a_follows_b_n01_u        = UNION e_n01_FOi, e_n01_FOo;
a_follows_b_n01_f        = DISTINCT a_follows_b_n01_u;
a_replies_b_n01_u        = UNION e_n01_REi, e_n01_REo;
a_replies_b_n01_f        = DISTINCT a_replies_b_n01_u;

-- Sort and compact the relationship sets
a_follows_b_n01          = ORDER   a_follows_b_n01_f        BY user_a_id, user_b_id PARALLEL $PARALLEL_MED ;
a_replies_b_n01          = ORDER   a_replies_b_n01_f        BY user_a_id, user_b_id PARALLEL $PARALLEL_MED ;

--
-- -- Store simple objects
--

-- -- Store user objects
-- rmf                                $HOOD/twitter_user_n01;
-- STORE TwitterUser_n01        INTO '$HOOD/twitter_user_n01';
-- rmf                                $HOOD/twitter_user_partial_n01;
-- STORE TwitterUserPartial_n01 INTO '$HOOD/twitter_user_partial_n01';
-- rmf                                $HOOD/twitter_user_profile_n01;
-- STORE TwitterUserProfile_n01 INTO '$HOOD/twitter_user_profile_n01';
-- rmf                                $HOOD/twitter_user_style_n01;
-- STORE TwitterUserStyle_n01   INTO '$HOOD/twitter_user_style_n01';
-- -- -- Store Tweet objects
-- rmf                                $HOOD/tweet_n01;
-- STORE Tweet_n01              INTO '$HOOD/tweet_n01';
-- rmf                                $HOOD/search_tweet_n01;
-- STORE SearchTweet_n01        INTO '$HOOD/search_tweet_n01';
-- 
-- -- -- Store n0+n1 relationships
-- rmf                                $HOOD/e_n01_FOi ;
-- STORE e_n01_FOi              INTO '$HOOD/e_n01_FOi';
-- rmf                                $HOOD/e_n01_FOo ;
-- STORE e_n01_FOo              INTO '$HOOD/e_n01_FOo';
-- rmf                                $HOOD/e_n01_REi ;
-- STORE e_n01_REi              INTO '$HOOD/e_n01_REi';
-- rmf                                $HOOD/e_n01_REo ;
-- STORE e_n01_REo              INTO '$HOOD/e_n01_REo';

-- Store combined edge neighborhoods
rmf                                $HOOD/a_follows_b_n01 ;
STORE a_follows_b_n01        INTO '$HOOD/a_follows_b_n01';
rmf                                $HOOD/a_replies_b_n01 ;
STORE a_replies_b_n01        INTO '$HOOD/a_replies_b_n01';
