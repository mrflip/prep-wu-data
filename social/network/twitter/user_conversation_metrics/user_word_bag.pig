-- user_word_bag.pig
--
-- Purpose: Make a dataset from word tokens consisting of the
-- following:
--
-- [user_id, word, num_user_word, tot_user_words, num_word, range]
--
-- where num_word and range are denormalized stats about the word.
--
-- Input data:
-- 
-- Uses only the word_token dataset from the output of extract_tweet_tokens.rb
-- which should look like:
--
-- [word_token, text, user_id, tweet_id, created_at]
--
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;

%default TOKENS  '/data/sn/tw/fixd/objects/tokens/word_token'; --input location
%default WORDBAG '/data/sn/tw/fixd/word/user_word_bag';        --output location

-- load input data
AllTokens = LOAD '$TOKENS' AS
            (
                rsrc:       chararray,
                text:       chararray,
                user_id:    long,
                tweet_id:   long,
                created_at: long
            );

-- get the number of usages for each user-word pair.  Result has exactly one entry per user-word pair.
UserToks        = FOREACH AllTokens GENERATE  user_id AS user_id, text AS tok ;
UserToksGrouped = GROUP UserToks BY (user_id, tok) PARALLEL 400;
UserTokCounts   = FOREACH UserToksGrouped GENERATE FLATTEN(group) AS (user_id, tok), COUNT(UserToks) AS num_user_tok_usages ;

-- For each user, get stats on their total word usage:
UserUsages      = GROUP UserTokCounts BY user_id  PARALLEL 400;
UserTokStats1   = FOREACH UserUsages GENERATE
    group                                                AS user_id                    ,
    FLATTEN( UserTokCounts.(tok, num_user_tok_usages) )  AS (tok, num_user_tok_usages) , 
    COUNT(   UserTokCounts)                              AS vocab                      , 
    SUM(UserTokCounts.num_user_tok_usages)               AS tot_user_usages            
    ;
UserTokStats    = FOREACH UserTokStats1 GENERATE
  tok, user_id,
  num_user_tok_usages,
  tot_user_usages,
  ((float)num_user_tok_usages / (float)tot_user_usages) AS user_tok_freq:float,
  ((float)num_user_tok_usages / (float)tot_user_usages)*((float)num_user_tok_usages / (float)tot_user_usages) AS user_tok_freq_sq:float,
  vocab ;
-- illustrate UserTokStats;

rmf                      $WORDBAG;
STORE UserTokStats INTO '$WORDBAG';


-- In the counters for the UserToksGrouped, the number of input rows is the total number of usages.
-- In the counters for the UserTokStats, the number of output rows is the number of users

-- %default SQRT_OF_N_USERS_MINUS_1 '1000.0' ;
-- %default TOT_USAGES_AS_DOUBLE    '1000000.0';

-- UserTokStatsGrouped = GROUP UserTokStats BY tok ;
-- TokStats = FOREACH UserTokStatsGrouped {
--   freq_avg         = AVG(UserTokStats.user_tok_freq);
--   freq_var         = AVG(UserTokStats.user_tok_freq_sq) - (AVG(UserTokStats.user_tok_freq) * AVG(UserTokStats.user_tok_freq));
--   freq_stdev       = org.apache.pig.piggybank.evaluation.math.SQRT(freq_var) ;
--   tot_tok_usages  = SUM(UserTokStats.num_user_tok_usages) ;
--   dispersion       = 1.0 - (freq_stdev / ( freq_avg * $SQRT_OF_N_USERS_MINUS_1 ));
--   rel_freq         = ((double)tot_tok_usages / $TOT_USAGES_AS_DOUBLE);  
--   GENERATE
--     group                     AS tok,
--     tot_tok_usages           AS tot_tok_usages,  -- total times THIS tok has been spoken
--     COUNT(UserTokStats)       AS range:     long,  -- total number of people who spoke this tok at least once
--     (float)freq_avg           AS freq_avg:  float -- average  of the frequencies at which this tok is spoken
--     , (float)freq_var         AS freq_var:  float -- variance of the frequencies at which this tok is spoken
--     , (float)freq_stdev       AS freq_stdev:float -- standard deviation of the frequencies at which this tok is spoken
--     , (float)dispersion         AS dispersion:float -- dispersion (see below)
--     , (float)rel_freq           AS rel_freq:  float  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
--     ;
--   };
-- illustrate TokStats ;
-- 
-- 
-- TokStats = FOREACH UserTokStatsGrouped {
--   freq_avg         = AVG(UserTokStats.user_tok_freq);
--   freq_var         = AVG(UserTokStats.user_tok_freq_sq) - (AVG(UserTokStats.user_tok_freq) * AVG(UserTokStats.user_tok_freq));
--   freq_stdev       = org.apache.pig.piggybank.evaluation.math.SQRT(freq_var) ;
--   GENERATE
--     group                     AS tok,
--     (float)freq_avg           AS freq_avg:  float
--     , (float)freq_stdev         AS freq_stdev:float
--     ;
--   };
-- illustrate TokStats ;


-- Dispersion is Julliand's D
-- 
--               V         
-- D = 1 - --------------- 
--           sqrt(n - 1)   
-- 
-- V = s / x
-- 	  
-- Where
-- 
-- * n is the number of users
-- * s is the standard deviation of the subfrequencies
-- * x is the average of the subfrequencies
  
