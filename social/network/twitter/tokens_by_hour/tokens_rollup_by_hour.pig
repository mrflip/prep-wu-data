-- ===========================================================================
--
-- tokens_by_hour.pig --
--
--   An hour-by-hour count of how often each hashtag, URL or smileyface
--   has been observed in our corpus.
--

%default SOURCE_FILE 'fixd/tw/tokens/all*'
%default TOKENS_BY_HOUR_FILE         'fixd/tw/tokens/tokens_by_hour'
%default TOTAL_TOKENS_BY_HOUR_FILE   'fixd/tw/tokens/total_tokens_by_hour'
%default REDUCERS    20

-- Divide created_at by: 10000.0 for hour, 1000000.0 for day, 100000000.0 for month.
%default TIMESLICE   10000.0

-- So we can use the LOWER function
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- Load
-- fixd/tw/tokens/toks
-- ,fixd/tw/tokens/all
Tokens = LOAD '$SOURCE_FILE' AS (
  rsrc:                 chararray,
  text:                 chararray,
  tweet_id:             long,
  twitter_user_id:      chararray, -- right now search_tweet tokens come out with username only
  created_at:           long
  );

-- Extract fields, take only hour from crat
Tokens_0 = FOREACH Tokens GENERATE
  rsrc,
  (long)((double)created_at / $TIMESLICE)                          AS crat_bin:long,
  (chararray)org.apache.pig.piggybank.evaluation.string.LOWER(text) AS text:chararray
  ;
TokensByHour_1 = GROUP Tokens_0 BY (rsrc, text, crat_bin) PARALLEL $REDUCERS;

-- Rollup by hour, do the count
TokensByHour_2 = FOREACH TokensByHour_1 GENERATE
  FLATTEN(group.rsrc)           AS rsrc,
  FLATTEN(group.crat_bin)       AS crat_bin,  
  COUNT(Tokens_0)               AS num,
  FLATTEN(group.text)           AS text
  ;
-- ILLUSTRATE TokensByHour_2;

-- Sort the tokens to be adjacent
TokensByHour_3 = ORDER TokensByHour_2 BY rsrc, text, crat_bin PARALLEL $REDUCERS;

-- Store
-- rmf                        $TOKENS_BY_HOUR_FILE
-- STORE TokensByHour_3 INTO '$TOKENS_BY_HOUR_FILE' ;
TokensByHour_3 = LOAD '$TOKENS_BY_HOUR_FILE' AS (rsrc:chararray, crat_bin:long, num:long, text:chararray);

-- Token Totals by Hour
TokensByHour_4      = FOREACH TokensByHour_3 GENERATE rsrc, crat_bin, num ;
TokenCountsByHour_0 = GROUP TokensByHour_4 BY (rsrc, crat_bin) ;
TokenCountsByHour_1 = FOREACH TokenCountsByHour_0 GENERATE
  FLATTEN(group.rsrc)           AS rsrc,
  FLATTEN(group.crat_bin)       AS crat_bin,  
  SUM(TokensByHour_4.num)       AS num
  ;
TokenCountsByHour_2 = ORDER TokenCountsByHour_1 BY crat_bin, rsrc ;
-- ILLUSTRATE TokenCountsByHour_1  ;

rmf                             $TOTAL_TOKENS_BY_HOUR_FILE ;
STORE TokenCountsByHour_2 INTO '$TOTAL_TOKENS_BY_HOUR_FILE' ;
TokenCountsByHour_2     = LOAD '$TOTAL_TOKENS_BY_HOUR_FILE' AS (rsrc:chararray, crat_bin:long, num:long);
