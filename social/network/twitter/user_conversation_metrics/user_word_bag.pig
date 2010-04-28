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

AllTokens = LOAD '$TOKENS' AS (
            rsrc:       chararray,
            text:       chararray,
            user_id:    long,
            tweet_id:   long,
            created_at: long
            );

AllWords   = FILTER AllTokens BY rsrc == 'word_token';
-- Group by both user id AND text
Grouped    = GROUP AllWords BY (user_id, text);
UserWords  = FOREACH Grouped GENERATE
                     group.user_id     AS user_id,
                     group.text        AS text,
                     COUNT(AllWords.text) AS num
                     ;

UserHist  = GROUP UserWords BY user_id;
-- results in:
--            [user_id, {(user_id, word, count), (user_id, word, count), ...} ]                     

FinalHist = FOREACH UserHist GENERATE group, UserWords.(text, num);
-- results in:
--            [user_id, {(word,count), (word, count), ... } ]
rmf $WORDBAG;
STORE FinalHist INTO '$WORDBAG';
