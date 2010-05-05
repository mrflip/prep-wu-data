-- ===========================================================================
--
-- tweet_tokens_by_time.pig --
--
--   An count of how often each hashtag, URL or smileyface
--   has been observed in our corpus by hour, day, or month depending on TIMESLICE.
--

%default INPUT_DATA                 '/data/rawd/social/network/twitter/objects/tokens/*'
%default OUTPUT_DATA                '/data/rawd/social/network/twitter/census/tokens_by_hour'

-- Divide created_at by: 10000.0 for hour, 1000000.0 for day, 100000000.0 for month.
-- hour
%default TIMESLICE   10000.0
-- month
-- %default TIMESLICE   100000000.0
-- day
-- %default TIMESLICE  1000000.0

-- So we can use the LOWER function
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- Load
-- fixd/tw/tokens/toks
-- ,fixd/tw/tokens/all
Tokens = LOAD '$INPUT_DATA' AS (
  rsrc:                 chararray,
  text:                 chararray,
  tweet_id:             long,
  twitter_user_id:      chararray, -- right now search_tweet tokens come out with username only
  created_at:           long
  );

-- Extract fields, take only up to time specified by TIMESLICE from created at (crat) field
TokensWTime = FOREACH Tokens GENERATE
  rsrc,
  (long)((double)created_at / $TIMESLICE)                           AS crat_bin:long,
  (chararray)org.apache.pig.piggybank.evaluation.string.LOWER(text) AS text:chararray
  ;
  
TokensByTime = GROUP TokensWTime BY (rsrc, text, crat_bin);

-- Rollup by hour, do the count
CountedTokensByTime = FOREACH TokensByTime GENERATE
  FLATTEN(group.rsrc)           AS rsrc,
  FLATTEN(group.crat_bin)       AS crat_bin,  
  COUNT(TokensWTime)            AS num,
  FLATTEN(group.text)           AS text
  ;
-- ILLUSTRATE CountedTokensByTime;

-- Sort the tokens to be adjacent
SortedTokensByTime = ORDER CountedTokensByTime BY rsrc, text, crat_bin;

-- Store
rmf                           $OUTPUT_DATA;
STORE SortedTokensByTime INTO '$OUTPUT_DATA';
