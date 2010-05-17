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
                tweet_id:   long,
                user_id:    chararray, --could be screen name OR long id
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
