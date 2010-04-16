
TwitterUserId = LOAD '/data/rawd/social/network/twitter/scrape_stats/twitter_user_ids' AS (
  rsrc:             chararray,
  id:               long,
  scraped_at:       long,
  screen_name:      chararray,
  protected:        int,
  followers_count:  long,
  friends_count:    long,
  statuses_count:   long,
  favourites_count: long,
  created_at:       chararray,
  sid:              long,
  is_full:          long,
  health:           chararray
  ) ;

TwitterUserSearchId     = LOAD '/data/rawd/social/network/twitter/objects/twitter_user_search_id' AS (
  rsrc:        chararray,
  screen_name: chararray,
  sid:         long,
  id:          long ) ;

MatchedIds_0 = JOIN
  TwitterUserSearchId BY screen_name FULL OUTER,
  TwitterUserId       BY screen_name
  ;

DESCRIBE    MatchedIds_0;
-- ILLUSTRATE TwitterUserId ;
  
MatchedIds_1 = FOREACH MatchedIds_0 GENERATE
  (TwitterUserId::rsrc IS NULL ? 'twitter_user_id-missing_api_id' : TwitterUserId::rsrc) AS rsrc:chararray,
  TwitterUserId::id                     AS id,
  TwitterUserId::scraped_at             AS scraped_at,  
  (TwitterUserId::screen_name IS NULL ? TwitterUserSearchId::screen_name : TwitterUserId::screen_name) AS screen_name,
  TwitterUserId::protected              AS protected,
  TwitterUserId::followers_count        AS followers_count,
  TwitterUserId::friends_count          AS friends_count,   
  TwitterUserId::statuses_count         AS statuses_count,  
  TwitterUserId::favourites_count       AS favourites_count,  
  TwitterUserId::created_at             AS created_at,
  TwitterUserSearchId::sid              AS sid,
  TwitterUserId::is_full                AS is_full,
  (TwitterUserId::rsrc IS NULL ? 'missing_api_id' : TwitterUserId::health) AS health:chararray
  ;

DESCRIBE    MatchedIds_1 ;
-- ILLUSTRATE TwitterUserId ;

MatchedIds_2 = ORDER MatchedIds_1
  BY rsrc, followers_count DESC, id ASC, sid ASC 
  ;

rmf                      /data/rawd/social/network/twitter/objects/twitter_user_id_matched ;
STORE MatchedIds_2 INTO '/data/rawd/social/network/twitter/objects/twitter_user_id_matched';


-- MatchedIds_2        = LOAD 'fixd/tw/meta/twitter_user_id_matched' AS (
--   rsrc:             chararray,
--   id:               long,
--   scraped_at:       long,
--   screen_name:      chararray,
--   protected:        int,
--   followers_count:  long,
--   friends_count:    long,
--   statuses_count:   long,
--   favourites_count: long,
--   created_at:       chararray,
--   sid:              long,
--   is_full:          long,
--   health:           chararray
-- );
-- MatchedIds_3 = FILTER MatchedIds_2 BY (health=='' OR health IS NULL) AND (protected == 0 OR protected IS NULL);
-- MatchedIds_4 = FOREACH MatchedIds_3 GENERATE 
--   rsrc, id, scraped_at, screen_name, protected,
--   followers_count,
--   -- friends_count, statuses_count, favourites_count,
--   created_at,
--   sid
--   ;
-- MatchedIds_5 = ORDER MatchedIds_4
--   BY rsrc, followers_count DESC, id ASC, sid ASC
--   ;
-- rmf                      fixd/tw/meta/twitter_user_id_mapping ;
-- STORE MatchedIds_5 INTO 'fixd/tw/meta/twitter_user_id_mapping';

-- 
-- ToScrape_0 = FILTER MatchedIds_2
--   BY (rsrc MATCHES 'twitter_user_id-(missing_sn|partial|missing_api_id)')
--   ;
-- 
-- ToScrape_1 = FOREACH ToScrape_0 GENERATE
--   rsrc,
--   ((id IS NULL) ? screen_name : ((chararray)id) ) AS id:chararray,
--   followers_count
--   ;
-- 
-- rmf                    fixd/tw/meta/scrape_request_twitter_users_20091107 ;
-- STORE ToScrape_1 INTO 'fixd/tw/meta/scrape_request_twitter_users_20091107';

