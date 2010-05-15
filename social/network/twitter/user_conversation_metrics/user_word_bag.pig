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
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

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
                        distinct_words = DISTINCT Words;
                        GENERATE group AS word, COUNT(Words) AS num_word, COUNT(distinct_words) AS range;
                };

-- make [user_id, word, user_count(word)] from input
UserWords     = GROUP Words BY (user_id, word);
UserWordStats = FOREACH UserWords GENERATE group.user_id AS user_id, group.word AS word, COUNT(Words) AS num_user_word;

-- make [user_id, sum_user_words, vocab] from input
Users = GROUP Words BY user_id;
UserStats = FOREACH Users
            {
                distinct_user_words = DISTINCT Words;
                GENERATE group AS user_id, COUNT(Words) AS sum_user_words, COUNT(distinct_user_words) AS vocab;
            };

-- do the first join to yield [user_id, word, num_user_word, sum_user_words, vocab]
JoinedUserWords = JOIN UserStats BY user_id, UserWordStats BY user_id;
FirstJoined     = FOREACH JoinedUserWords GENERATE
                        UserStats::user_id           AS user_id,
                        UserWordStats::word          AS word,
                        UserWordStats::num_user_word AS num_user_word,
                        UserStats::sum_user_words    AS sum_user_words,
                        UserStats::vocab             AS vocab
                  ;
-- do the second join to yield [user_id, word, num_user_word, sum_user_words, num_word, range]
JoinedAllWords = JOIN WordStats BY word, FirstJoined BY word;
FinalStats     = FOREACH JoinedAllWords GENERATE
                        FirstJoined::user_id        AS user_id,
                        FirstJoined::word           AS word,
                        FirstJoined::num_user_word  AS num_user_word,
                        FirstJoined::sum_user_words AS sum_user_words,
                        FirstJoined::vocab          AS vocab,
                        WordStats::num_word         AS num_word,
                        WordStats::range            AS range
                 ;

-- store data on disk             
rmf $WORDBAG;
STORE FinalStats INTO '$WORDBAG';
