-- In the counters for the UserToksGrouped, the number of input rows is the total number of usages.
-- In the counters for the UserTokStats, the number of output rows is the number of users

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;
%default WORDBAG   '/data/sn/tw/fixd/word/user_word_bag';     --input location
%default WORDSTATS '/data/sn/tw/fixd/word/global_word_stats'; --output location
%default SQRT_OF_N_USERS_MINUS_1 '7305.3931';
%default TOT_USAGES_AS_DOUBLE    '14876543916.0';

UserTokStats = LOAD '$WORDBAG' AS
               (
                        tok:                 chararray,
                        user_id:             chararray, --could be screen name OR long id
                        num_user_tok_usages: long,
                        tot_user_usages:     long,
                        user_tok_freq:       float,
                        user_tok_freq_sq:    float,
                        vocab:               long
               );

UserTokStatsGrouped = GROUP UserTokStats BY tok;
TokStats = FOREACH UserTokStatsGrouped
           {
                freq_avg         = AVG(UserTokStats.user_tok_freq);
                freq_var         = AVG(UserTokStats.user_tok_freq_sq) - (AVG(UserTokStats.user_tok_freq) * AVG(UserTokStats.user_tok_freq));
                freq_stdev       = org.apache.pig.piggybank.evaluation.math.SQRT(freq_var) ;
                tot_tok_usages   = SUM(UserTokStats.num_user_tok_usages) ;
                dispersion       = 1.0 - (freq_stdev / ( freq_avg * $SQRT_OF_N_USERS_MINUS_1 ));
                rel_freq         = ((double)tot_tok_usages / $TOT_USAGES_AS_DOUBLE);  
                GENERATE
                        group               AS tok,
                        tot_tok_usages      AS tot_tok_usages,    -- total times THIS tok has been spoken
                        COUNT(UserTokStats) AS range:      long,  -- total number of people who spoke this tok at least once
                        (float)freq_avg     AS freq_avg:   float, -- average  of the frequencies at which this tok is spoken
                        (float)freq_var     AS freq_var:   float, -- variance of the frequencies at which this tok is spoken
                        (float)freq_stdev   AS freq_stdev: float, -- standard deviation of the frequencies at which this tok is spoken
                        (float)dispersion   AS dispersion: float, -- dispersion (see below)
                        (float)rel_freq     AS rel_freq:   float  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
                ;
           };


rmf $WORDSTATS;
STORE TokStats INTO '$WORDSTATS';
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
