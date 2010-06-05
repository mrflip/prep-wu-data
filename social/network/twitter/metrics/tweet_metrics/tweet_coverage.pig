-- ===========================================================================
--
-- tokens_by_hour.pig --
--
--   An hour-by-hour count of how often each hashtag, URL or smileyface
--   has been observed in our corpus.
--

-- %default SOURCE_FILE 'ripd/com.tw/sampled/parsed/com.twitter3/tweet.tsv'
%default SOURCE_FILE 'fixd/tw/out/*tweet'
%default DEST_FILE   'fixd/tw/tweet_metrics/tweet_coverage'
%default REDUCERS    20

-- Piggybank
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- Load
Tweet               = LOAD '$SOURCE_FILE' AS (
  rsrc:          chararray,     id:             long,
  created_at:    long,          user_id:        long,
  favorited:     long,          truncated:      long,
  repl_user_id:  long,          repl_tw_id:     long,
  text:          chararray,     src:            chararray
  );

-- Extract fields, take only hour from crat
-- Divide created_at by: 10000.0 for hour, 1000000.0 for day, 100000000.0 for month.
Tweet_0 = FOREACH Tweet GENERATE
  id,
  (long)((double)created_at / 10000.0) AS crat_bin:long
  ;
TwCov_1 = GROUP Tweet_0 BY (crat_bin) PARALLEL $REDUCERS;

-- Rollup by hour, do the count
TwCov_2 = FOREACH TwCov_1 GENERATE
  FLATTEN(group)                        AS crat_bin,  
  MIN(Tweet_0.id)                       AS min_id,
  COUNT(Tweet_0)                        AS tw_seen,
  1 + MAX(Tweet_0.id) - MIN(Tweet_0.id) AS tw_total,
  ( ((double)COUNT(Tweet_0)) / ((double)(1 + MAX(Tweet_0.id) - MIN(Tweet_0.id))) ) AS frac_seen
  ;
-- ILLUSTRATE TwCov_2 ;

TwCov_3 = ORDER TwCov_2 BY crat_bin ASC ;

-- Store
rmf                 $DEST_FILE
STORE TwCov_3 INTO '$DEST_FILE' ;
