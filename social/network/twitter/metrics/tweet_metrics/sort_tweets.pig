Tweet               = LOAD 'fixd/tw/out/tweet' AS (
  rsrc: chararray, tw_id: long,
  created_at: long, user_id: long, favorited: long, truncated: long,
  repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray );

TwitterUserId = LOAD 'fixd/tw/meta/twitter_user_id_matched' AS (
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
);


-- chow = FILTER Tweet BY (user_id == 627363) ;
-- STORE chow INTO 'tmp/chow' ;

-- tw1 = ORDER Tweet BY tw_id ASC PARALLEL 88;
-- rmf             tmp/tweets_sorted;
-- STORE tw1 INTO 'tmp/tweets_sorted';
tw1 = LOAD 'tmp/tweets_sorted' AS (
  rsrc: chararray, tw_id: long,
  created_at: long, user_id: long, favorited: long, truncated: long,
  repl_user_id: long, repl_tw_id: long, text: chararray, src: chararray );

tw2 = LIMIT tw1 1001 ;

tw3 = JOIN TwitterUserId BY id RIGHT, tw2 BY user_id ;
tw4 = ORDER tw3 BY tw_id ASC PARALLEL 1;
rmf             tmp/tweets_first_k;
STORE tw4 INTO 'tmp/tweets_first_k';
