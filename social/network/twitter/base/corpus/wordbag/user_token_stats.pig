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
-- REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar ;
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;

%default TOKENS  '/data/sn/tw/fixd/objects/word_token'; --input location
%default WORDBAG '/data/sn/tw/fixd/word/user_word_bag'; --output location
toks        = LOAD '$TOKENS' AS (rsrc:chararray, text:chararray, twid:long, uid:long, crat:long);

-- generate flat user word usage counts
user_toks   = FOREACH toks GENERATE uid AS uid, text AS tok;
grouped     = GROUP user_toks BY (uid, tok);
user_counts = FOREACH grouped GENERATE FLATTEN(group) AS (uid, tok), COUNT(user_toks) AS num_user_tok_usages;

-- generate unique list of num token usages, unique usages overall, and total usages of all words by user
user_usages = GROUP user_counts BY uid;
usage_stats = FOREACH user_usages GENERATE
                  group                                           AS uid,
                  FLATTEN(user_counts.(tok, num_user_tok_usages)) AS (tok, num_user_tok_usages), 
                  COUNT(user_counts)                              AS vocab, 
                  SUM(user_counts.num_user_tok_usages)            AS tot_user_usages            
              ;

-- generate final user usage statistics for use in global statistics
user_stats  = FOREACH usage_stats
              {
                  user_tok_freq    = ((double)num_user_tok_usages / (double)tot_user_usages);
                  user_tok_freq_sq = ((double)num_user_tok_usages / (double)tot_user_usages)*((double)num_user_tok_usages / (double)tot_user_usages);
                  GENERATE
                      tok                 AS tok,
                      uid                 AS uid,
                      num_user_tok_usages AS num_user_tok_usages,
                      tot_user_usages     AS tot_user_usages,
                      user_tok_freq       AS user_tok_freq:double,
                      user_tok_freq_sq    AS user_tok_freq_sq:double,
                      vocab               AS vocab
                  ;
              };

rmf $WORDBAG;
STORE user_stats INTO '$WORDBAG';
