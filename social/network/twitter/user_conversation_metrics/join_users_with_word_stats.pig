-- desired output:
--
-- [user_id, word, A(word), B(word), ... ]
--
-- where A, B, etc are stats on the word
--

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

%default WORDBAG   '/data/sn/tw/fixd/word/user_word_bag';     --input location
%default WORDSTATS '/data/sn/tw/fixd/word/global_word_stats'; --input location
%default USERIDS   '/data/sn/tw/fixd/objects/twitter_user_id_matched'
%default USERWORDS '/data/sn/tw/fixd/word/user_word_bag_with_stats'; --output location

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
           
MatchedIds = LOAD '$USERIDS' AS (
                  rsrc:             chararray,
                  user_id:          long,
                  scraped_at:       long,
                  screen_name:      chararray,
                  protected:        int,
                  followers_count:  long,
                  friends_count:    long,
                  statuses_count:   long,
                  favourites_count: long,
                  created_at:       long,
                  search_id:        long,
                  is_full:          long,
                  health:           chararray
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
                        
-- JoinedWNames = JOIN UserBagsWStats BY user_id, MatchedIds BY user_id;
-- DUMP JoinedWNames;

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
