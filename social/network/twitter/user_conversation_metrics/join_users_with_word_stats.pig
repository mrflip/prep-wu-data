-- desired output:
--
-- [user_id, word, A(word), B(word), ... ]
--
-- where A, B, etc are stats on the word
--

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

%default WORDBAG   '/data/social/network/twitter/fixd/word/user_word_bag';     --input location
%default WORDSTATS '/data/social/network/twitter/fixd/word/global_word_stats'; --input location
%default USERWORDS '/data/social/network/twitter/fixd/word/user_word_bag_with_stats'; --output location

-- load input data
AllHists = LOAD '$WORDBAG' AS
           (
                user_id:  long,
                text:     chararray,
                num:      long,
                rel_freq: float
           );

AllStats = LOAD '$WORDSTATS' AS
           (
                text:     chararray,
                num:      long,
                range:    int,
                freq_var: float,
                freq_avg: float,
                rel_freq: float
           );
           
Joined         = JOIN AllHists BY text, AllStats BY text;
UserBagsWStats = FOREACH Joined GENERATE
                        AllHists::user_id  AS user_id,
                        AllHists::text     AS word,
                        AllHists::num      AS user_word_count,
                        AllHists::rel_freq AS user_word_rel_freq,
                        AllStats::num      AS raw_stream_count,
                        AllStats::range    AS word_range,
                        AllStats::freq_var AS freq_var,
                        AllStats::freq_avg AS freq_avg,
                        AllStats::rel_freq AS ratio
                        ;

rmf $USERWORDS;
STORE UserBagsWStats INTO '$USERWORDS';

--
-- SCHEMA:
--
-- user_id      word    user_word_count user_word_rel_freq    count   range   freq_var        freq_avg        ratio
--
-- user_id            = twitter user id we are concerned with
-- word               = raw text of 'word'
-- user_word_count    = number of times user has tweeted the word
-- user_word_rel_freq = user_word_count/sum(all user's words)
-- count              = number of times the word has shown up ever
-- range              = number of people who have used word at least once
-- freq_var           = variance of the set of all user_word_counts
-- freq_avg           = average of the set of all user_word_counts
-- ratio              = count/N where N is the total number of words ever tweeted
-- 
