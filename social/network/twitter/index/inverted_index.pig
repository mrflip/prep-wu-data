-- inverted_index.pig
-- 
-- Purpose: Make a dataset from all the tokens consisting of
-- the following:
--
-- [ rsrc, tweet_id, text]
--
-- that can be used to map from words, hastags, smileys,
-- etc. to tweets via the tweet id.
-- 
-- Input data:
-- 
-- Uses the output of extract_tweet_tokens.rb
-- which should look like:
--
--    rsrc     text             user_id  tweet_id  created_at
--    word     pajamas          user_id  tweet_id  created_at
--    hashtag  aprilfools       user_id  tweet_id  created_at
--    url      http://trst.me   user_id  tweet_id  created_at
--    word     bob              user_id  tweet_id  created_at
--
-- tokens include (stock tokens, word tokens, hashtags, urls, and smileys).
-- Note: A tweet like 'bork bork bork' will show up as three different tokens in this input file.
-- 
--
%default TOKENS  '/data/social/network/twitter/fixd/objects/tokens/*';     --input location
%default INDEXED '/data/social/network/twitter/fixd/index/inverted_index'; --output location

AllTokens = LOAD '$TOKENS' AS (
            rsrc:       chararray,
            text:       chararray,
            user_id:    long,
            tweet_id:   long,
            created_at: long
            );

CutTokens     = FOREACH AllTokens GENERATE rsrc, tweet_id, text;
UniqTokens    = DISTINCT CutTokens;

rmf $INDEXED;
STORE UniqTokens INTO '$INDEXED'; -- [ rsrc, tweet_id, text ]
