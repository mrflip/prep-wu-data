-- user_word_bag.pig
--
-- Purpose: Make a dataset from word tokens consisting of the
-- following:
--
-- [user_id, word, num_user_word, sum_user_words, num_word, range]
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
            
Words = FOREACH AllTokens GENERATE
                text    AS word,
                user_id AS user_id
                ;
                
-- make [word, count(word), range(word)] from input
GlobalWords   = GROUP Words BY word;
WordStats     = FOREACH GlobalWords
                {
                        --num_word = count of times word has been used
                        --range    = number of people who have used word at least once
                        num_word = COUNT(Words);
                        range    = COUNT(DISTINCT(Words));
                        GENERATE
                                group    AS word,
                                num_word AS num_word,
                                range    AS range
                        ;                        
                };

-- make [user_id, word, user_count(word)] from input
UserWords     = GROUP Words BY (user_id, word);
UserWordStats = FOREACH UserWords
                {
                        --num_user_word = count of times user has used word
                        num_user_word = COUNT(Words);
                        GENERATE
                                group.user_id AS user_id,
                                group.word    AS word,
                                num_user_word AS num_user_word
                        ;                                
                };

-- do a join to yield [user_id, word, num_user_word, sum_user_words, num_word, range]                
JoinedStats = JOIN UserWordStats BY word, WordStats BY word;
FinalStats  = FOREACH JoinedStats
              {
                --sum_user_words = count of all words user has ever spoken
                sum_user_words = SUM(UserWordStats::num_user_word);
                GENERATE
                        UserWordStats::user_id AS user_id,
                        UserWordStats::word    AS word,
                        UserWordStats::num_user_word AS num_user_word,
                        sum_user_words AS sum_user_words,
                        WordStats::num_word AS num_word,
                        WordStats::range    AS range
                ;                        
              };

-- -- store data on disk             
rmf $WORDBAG;
STORE FinalFlattened INTO '$WORDBAG';
