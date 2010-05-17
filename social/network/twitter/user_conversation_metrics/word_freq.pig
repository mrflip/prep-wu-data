
-- Quickie script to get top token counts: group on words, count group


-- Note: SAMPLED!!! Doesn't read in whole thing
-- 
%default TOKENS     '/data/sn/tw/fixd/objects/tokens/word_token/part-0000*'; --input location
%default TOK_COUNTS '/data/sn/tw/fixd/word/sampled_tok_counts';              --output location

-- load input data
AllTokens = LOAD '$TOKENS' AS ( rsrc: chararray, text: chararray, user_id: long, tweet_id: long, created_at: long );

-- get the number of usages for each user-word pair.  Result has exactly one entry per user-word pair.
Toks            = FOREACH AllTokens GENERATE text AS tok ;
ToksGrouped     = GROUP   Toks BY tok PARALLEL 5;
TokCounts       = FOREACH ToksGrouped GENERATE COUNT(Toks) AS num_usages, FLATTEN(group) AS tok;

rmf                   $TOK_COUNTS;
STORE TokCounts INTO '$TOK_COUNTS';
