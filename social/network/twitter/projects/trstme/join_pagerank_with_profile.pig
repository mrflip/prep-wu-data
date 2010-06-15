-- params

--   TWITTER_USER_IDS = path to complete list of twitter user profiles
--   PAGERANK         = path to pagerank and id
--   TRSTME           = path to final output date for trst me app


MatchedIds = LOAD '$TWITTER_USER_IDS' AS (
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

-- PAGERANK = '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_only'

Rank = LOAD '$PAGERANK' AS (
  user_id:              long,
  pagerank:             float
  ) ;

RankWScreenNames = JOIN Rank BY user_id, MatchedIds BY id;

OutputTweets = FOREACH RankWScreenNames GENERATE

  MatchedIds::screen_name               AS screen_name,
  MatchedIds::id                        AS user_id,
  Rank::pagerank                        AS pagerank,  
  MatchedIds::followers_count           AS followers_count,
  MatchedIds::friends_count             AS friends_count,
  MatchedIds::statuses_count            AS statuses_count,
  MatchedIds::created_at                AS created_at
  ;

-- TRSTME '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_with_profile'

rmf                      $TRSTME;
STORE OutputTweets INTO '$TRSTME';
