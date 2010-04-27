MatchedIds = LOAD '/data/rawd/social/network/twitter/objects/twitter_user_id_matched' AS (
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

Rank = LOAD '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_only' AS (
  user_id:              long,
  pagerank:             float
  ) ;

RankWScreenNames = JOIN Rank BY user_id, MatchedIds BY id;

OutputTweets = FOREACH RankWScreenNames GENERATE

--  MatchedIds::screen_name               AS screen_name,
  MatchedIds::id                        AS user_id,
  Rank::pagerank                        AS pagerank,  
  MatchedIds::followers_count           AS followers_count,
  (((double) MatchedIds::followers_count)/( (double) MatchedIds::friends_count) ) AS ratio,
--  MatchedIds::friends_count             AS friends_count,
--  MatchedIds::statuses_count            AS statuses_count,
  MatchedIds::created_at                AS created_at
  ;

rmf                      /data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_with_profile;
STORE OutputTweets INTO '/data/rawd/social/network/twitter/pagerank/a_follows_b_pagerank/pagerank_with_profile';
