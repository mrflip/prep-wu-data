-- global_token_stats.pig
--
-- Purpose: Make a dataset from tokens consisting of the following:
--
-- [token, count(token), count(token)/sum(all_tokens), dispersion(token), range(token)]
-- 
-- Input data:
-- 
-- Simply use the output of user_word_bag.pig
--    user_id:long, text:chararray, num:long, rel_freq:double
--
%default WORDBAG   '/data/social/network/twitter/fixd/word/user_word_bag';     --input location
%default WORDSTATS '/data/social/network/twitter/fixd/word/global_word_stats'; --output location

-- load input data
AllHists = LOAD '$WORDBAG' AS
           (
                user_id:long,
                text:chararray,
                num:long,
                rel_freq:double
           );
           
            
-- rmf $WORDSTATS;
-- STORE FinalHist INTO '$WORDSTATS';
