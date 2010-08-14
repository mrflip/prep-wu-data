-- usage_user_stats.pig
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

%default TOKENS       '/data/sn/tw/fixd/objects/word_token'; --input location
%default WORDBAG_ROOT '/data/sn/tw/fixd/wordbag';            --output location
usages      = LOAD '$TOKENS' AS (rsrc:chararray, text:chararray, twid:long, uid:long, crat:long);

-- Count usages for each token by each user
user_toks_0 = FOREACH usages GENERATE uid AS uid, text AS tok;
user_toks_g = GROUP   user_toks_0 BY (uid, tok);
user_toks   = FOREACH user_toks_g GENERATE FLATTEN(group) AS (uid, tok), COUNT(user_toks_0) AS num_user_tok_usages;

-- For each user, find out tot_user_usages (times they said anything) and vocab (distinct tokens)
-- project back down onto each user_tok pair
user_tok_user_stats_g = GROUP user_toks BY uid;
user_tok_user_stats_1 = FOREACH user_tok_user_stats_g GENERATE
  group                                          AS uid,
  FLATTEN(user_toks.(tok, num_user_tok_usages))  AS (tok, num_user_tok_usages), 
  COUNT(user_toks)                               AS vocab, 
  SUM(user_toks.num_user_tok_usages)             AS tot_user_usages
  ;

-- generate user-token pairs with denormalized user stats
user_tok_user_stats = FOREACH user_tok_user_stats_1 {
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

rmf                             $WORDBAG_ROOT/user_tok_user_stats;
STORE user_tok_user_stats INTO '$WORDBAG_ROOT/user_tok_user_stats';
user_tok_user_stats     = LOAD '$WORDBAG_ROOT/user_tok_user_stats' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
