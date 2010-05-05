-- global_token_stats.pig
--
-- Purpose: Make a dataset from tokens consisting of the following:
--
-- [word, count(word), range(word), var(word), avg(word), count(word)/count(all_words)]
--
-- When we have a better version of pig need to add the dispersion(word)
--
-- Input data:
-- 
-- Simply use the output of user_word_bag.pig
--    user_id:long, text:chararray, num:long, rel_freq:double
--

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

%default WORDBAG   '/data/social/network/twitter/fixd/word/user_word_bag';     --input location
%default GLOBALTOT '/data/social/network/twitter/fixd/word/global_totals';
%default WORDSTATS '/data/social/network/twitter/fixd/word/global_word_stats'; --output location
%default TOKEN_TOTAL '847114.0'; -- this will need to be read in as a parameter
%default N_USERS     '812142.0'; -- read in as a parameter


-- load input data
AllHists = LOAD '$WORDBAG' AS
           (
                user_id:  long,
                text:     chararray,
                num:      long,
                rel_freq: float
           );

           
AllTokens = FOREACH AllHists GENERATE user_id, text, num AS freq, (1.0*(float)num*(float)num) AS freq_sq;

-- global token stats
GroupedTokens = GROUP AllTokens ALL;
GlobalStats   = FOREACH GroupedTokens {
                        freq_var = AVG(AllTokens.freq_sq) - (AVG(AllTokens.freq) * AVG(AllTokens.freq));
                        freq_avg = AVG(AllTokens.freq);
                        GENERATE
                        (float)freq_var     AS freq_var: float,
	                (float)freq_avg     AS freq_avg: float,
                        SUM(AllTokens.freq) AS total_tokens, -- ie. total number of words ever spoken
                        COUNT(AllTokens)    AS n_users;      -- ie. total number of people who ever ever said at least one word
                        };
-- rmf $GLOBALTOT;
-- STORE GlobalStats INTO '$GLOBALTOT';
                        
-- word stats
WordGroup      = GROUP AllTokens BY text;
WordStatistics = FOREACH WordGroup {
                        freq_var     = AVG(AllTokens.freq_sq) - (AVG(AllTokens.freq) * AVG(AllTokens.freq));
                        freq_avg     = AVG(AllTokens.freq);
                        freq_tot     = SUM(AllTokens.freq);
                        -- because pig hates me, this line is commented out (need a newer version)
--                        dispersion   = 1.0 - SQRT(freq_var)/(freq_avg*SQRT((float)'$N_USERS'-1.0));
                        rel_freq     = (1.0*(float)freq_tot/(float)'$TOKEN_TOTAL');
                        GENERATE group 	              AS word,
                                freq_tot              AS freq,   -- total times THIS word has been spoken
	                        (int)COUNT(AllTokens) AS range:    int,   -- total number of people who spoke this word at least once
	                        (float)freq_var       AS freq_var: float, -- variance of of the frequencies at which this word is spoken
	                        (float)freq_avg       AS freq_avg: float, -- average  of the frequencies at which this word is spoken
--                                dispersion            AS dispersion,
                                (float)rel_freq       AS rel_freq; -- total times THIS word has been spoken out of the total words that
                                                                   -- have EVER been spoken
                        };
                        
OrderedStats = ORDER WordStatistics BY freq DESC;
rmf $WORDSTATS;
STORE OrderedStats INTO '$WORDSTATS';

-- Range is how many people used the word

-- Dispersion is Julliand's D
-- 
--               V
-- D = 1 - ---------------
--           sqrt(n - 1)
-- 
-- V = s / x
-- 	  
-- Where
-- 
-- * n is the number of users
-- * s is the standard deviation of the subfrequencies
-- * x is the average of the subfrequencies
