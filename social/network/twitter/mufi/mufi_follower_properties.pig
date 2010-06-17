-- TwitterUserId      
-- [:id,                     Integer]
-- [:scraped_at,             Bignum]
-- [:screen_name,            String]
-- [:protected,              Integer]
-- [:followers_count,        Integer]
-- [:friends_count,          Integer]
-- [:statuses_count,         Integer]
-- [:favourites_count,       Integer]
-- [:created_at,             Bignum ]
-- [:sid,                    Integer]
-- [:is_full,                Integer]
-- [:health,                 String]

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default MUFI_ID '23866990' ;
%default PAGERANK '/data/sn/tw/pagerank/a_follows_b_pagerank/pagerank_only' ;
%default A_FOLLOWS_B '/data/sn/tw/fixd/objects/a_follows_b' ;
%default USER_STAT '/data/sn/tw/fixd/objects/twitter_user_id_matched' ;
%default USER_PROFILE '/data/sn/tw/fixd/objects/twitter_user_profile' ;
%default TWEET '/data/sn/tw/fixd/objects/tweet' ;
%default SEARCH_TWEET '/data/sn/tw/fixd/objects/search_tweet' ;

%default MUFI_FOLLOWER_PAGERANK '/data/anal/mufi/follower_pagerank' ;
%default MUFI_FOLLOWER_STAT  '/data/anal/mufi/follower_stat'  ;
%default MUFI_FOLLOWER_PROFILE  '/data/anal/mufi/follower_profile'  ; -- do this
%default MUFI_FOLLOWER_TWEET    '/data/anal/mufi/follower_tweet'    ; -- do this
%default MUFI_TWEET             '/data/anal/mufi/mufi_tweet'        ;
%default ID_MAPPING '/data/sn/tw/fixd/objects/twitter_user_id_matched' ;

id_mapping = LOAD '$ID_MAPPING' AS (
	rsrc:chararray,
	id:long,
	scraped_at:long,
	screen_name:chararray,
	protected:int,
	followers_count:long,
	friends_count:long,
	statuses_count:long,
	favourites_count:long,
	created_at:long,
	sid:long,
	is_full:int,
	health:chararray
	);

-- pagerank     = LOAD '$PAGERANK'     AS (user_id:long, pagerank:float);
a_follows_b  = LOAD '$A_FOLLOWS_B'  AS (rsrc:chararray, user_a_id:long, user_b_id:long);
-- user_stat         = LOAD '$USER_STAT'         AS (rsrc:chararray, id:long, scraped_at:long, screen_name:chararray, protected:int, followers:int, friends:int, statuses:int, favorites:int, created_at:long, sid:int, is_full:int, health:chararray);
-- user_profile         = LOAD '$USER_PROFILE'         AS (rsrc:chararray, id:long, scraped_at:long, screen_name:chararray, url:chararray, location:chararray, description:chararray, time_zone:chararray, utc_offset:chararray);

tweet        = LOAD '$TWEET'        AS (rsrc:chararray, id:long, created_at:long, user_id:long, favorited:int, truncated:int, reply_to_user_id:long, reply_to_status_id:long, text:chararray, source:chararray, reply_to_screen_name:chararray) ;

search_tweet = LOAD '$SEARCH_TWEET' AS (rsrc:chararray, id:long, created_at:long, user_id:long, favorited:int, truncated:int, reply_to_user_id:long, reply_to_status_id:long, text:chararray, source:chararray, reply_to_screen_name:chararray, reply_to_sid:int, user_screen_name:chararray, user_sid:int, language:chararray) ;

mufi_follow                      = FILTER  a_follows_b      BY user_b_id == $MUFI_ID;
mufi_follower_id                 = FOREACH mufi_follow      GENERATE user_a_id         AS id:long;
-- mufi_follower_id_joined_pagerank = JOIN    mufi_follower_id BY id, pagerank            BY user_id;
-- mufi_follower_id_and_pagerank    = FOREACH mufi_follower_id_joined_pagerank            GENERATE mufi_follower_id::id, pagerank::pagerank;
-- rmf $MUFI_FOLLOWER_PAGERANK
-- STORE mufi_follower_id_and_pagerank INTO '$MUFI_FOLLOWER_PAGERANK';

-- mufi_follower_joined_stat = JOIN mufi_follower_id BY id, user_stat BY id;
-- mufi_follower_stat           = FOREACH mufi_follower_joined_stat GENERATE user_stat::id, user_stat::scraped_at, user_stat::screen_name, user_stat::protected, user_stat::followers, user_stat::friends, user_stat::statuses, user_stat::favorites, user_stat::created_at;
-- rmf $MUFI_FOLLOWER_STAT ;
-- STORE mufi_follower_stat INTO '$MUFI_FOLLOWER_STAT';

-- mufi_follower_joined_profile = JOIN user_profile BY id, mufi_follower_id BY id USING "replicated" ;
-- mufi_follower_profile           = FOREACH mufi_follower_joined_profile GENERATE user_profile::id, user_profile::scraped_at, user_profile::screen_name, user_profile::url, user_profile::location, user_profile::description, user_profile::utc_offset ;
-- rmf $MUFI_FOLLOWER_PROFILE ;
-- STORE mufi_follower_profile INTO '$MUFI_FOLLOWER_PROFILE';

	

mufi_follower_joined_tweet = JOIN mufi_follower_id BY id, tweet by user_id;
mufi_follower_tweet_only = FOREACH mufi_follower_joined_tweet GENERATE tweet::id, tweet::created_at, tweet::user_id, tweet::favorited, tweet::truncated, tweet::source, tweet::text;

search_tweet_joined_id_mapping = JOIN id_mapping by sid, search_tweet by user_sid;
search_tweet_good_id           = FOREACH search_tweet_joined_id_mapping GENERATE search_tweet::id AS id, search_tweet::created_at AS created_at, id_mapping::id AS user_id, search_tweet::favorited AS favorited, search_tweet::truncated AS truncated, search_tweet::source AS source, search_tweet::text AS text;

mufi_follower_joined_search_tweet = JOIN mufi_follower_id BY id, search_tweet_good_id by user_id;
mufi_follower_search_tweet_only = FOREACH mufi_follower_joined_search_tweet GENERATE search_tweet_good_id::id, search_tweet_good_id::created_at, search_tweet_good_id::user_id, search_tweet_good_id::favorited, search_tweet_good_id::truncated, search_tweet_good_id::source, search_tweet_good_id::text;

mufi_follower_tweet = UNION mufi_follower_tweet_only, mufi_follower_search_tweet_only;
rmf $MUFI_FOLLOWER_TWEET 
STORE mufi_follower_tweet INTO '$MUFI_FOLLOWER_TWEET' ;

-- mu_t = FILTER tweet BY user_id == $MUFI_ID ;
-- mufi_tweet_only  = FOREACH mu_t GENERATE id, created_at, user_id, favorited, truncated, source, text;

-- mu_s = FILTER search_tweet BY user_id == $MUFI_ID ;
-- mufi_search_tweet_only  = FOREACH mu_s GENERATE id, created_at, user_id, favorited, truncated, source, text;

-- mufi_tweet = UNION mufi_tweet_only, mufi_search_tweet_only;
-- rmf $MUFI_TWEET
-- STORE mufi_tweet INTO '$MUFI_TWEET' ;

