-- user_word_bag.pig
--
-- Purpose: Make a dataset from word tokens consisting of the
-- following:
--
-- [user_id, {(word, count), (word,count), ...}]
-- 
-- Input data:
-- 
-- Uses only the word tokens from the output of extract_tweet_tokens.rb
-- which should look like:
--
-- [word, pajamas, user_id, tweet_id, created_at]
--
%default TOKENS  '/data/social/network/twitter/fixd/objects/tokens/word_token'; --input location
%default WORDBAG '/data/social/network/twitter/fixd/word/user_word_bag';        --output location

-- load input data
AllTokens = LOAD '$TOKENS' AS
            (
                rsrc:       chararray,
                text:       chararray,
                user_id:    long,
                tweet_id:   long,
                created_at: long
            );
            
-- make [user_id, pajamas, num_pajamas] from input
AllWords  = FILTER AllTokens BY rsrc == 'word_token';
Grouped   = GROUP AllWords BY (user_id, text);
UserWords = FOREACH Grouped GENERATE
            group.user_id        AS user_id,
            group.text           AS text,
            COUNT(AllWords.text) AS num
            ;
            
-- make [user_id, sum(all user's words), {(pajamas, num_pajamas), (fruit, num_fruit), ... }] 
UserHist  = GROUP UserWords BY user_id;
CountHist = FOREACH UserHist
            {
                n_count = SUM(UserWords.num);    
                GENERATE group AS user_id, n_count as n_count, UserWords.(text, num) AS pair;
            };

-- make [user_id, pajamas, num_pajamas, num_pajamas/sum(all user's words)]            
FlattenedHist = FOREACH CountHist GENERATE user_id, n_count, FLATTEN(pair);
YetMore       = FOREACH FlattenedHist GENERATE
                        user_id                         AS user_id,
                        pair::text                      AS text,
                        pair::num                       AS num,
                        (1.0*(float)num/(float)n_count) AS rel_freq
                ;

-- make [user_id, {(word, count, frequency), (word, count, frequency), ... }]                
AlmostHist = GROUP YetMore BY user_id;
FinalHist  = FOREACH AlmostHist GENERATE
                     group                         AS user_id,
                     YetMore.(text, num, rel_freq) AS big_bag
             ;
FinalFlattened = FOREACH FinalHist GENERATE user_id, FLATTEN(big_bag);
-- store data on disk             
rmf $WORDBAG;
STORE FinalFlattened INTO '$WORDBAG';
