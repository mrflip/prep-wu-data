-- In the counters for the UserToksGrouped, the number of input rows is the total number of usages.
-- In the counters for the UserTokStats, the number of output rows is the number of users

-- REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;

%default WORDBAG                 '/data/soc/net/tw/fixd/word/user_word_bag';     --input location
%default WORDSTATS               '/data/soc/net/fixd/word/global_word_stats'; --output location
%default SQRT_OF_N_USERS_MINUS_1 '7305.3931';
%default N_USERS                 '53368769.0';
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
                -- user token frequency stats (taken over participating users only)
                user_freq_avg     = AVG(UserTokStats.user_tok_freq);
                user_freq_var     = (float)AVG(UserTokStats.user_tok_freq_sq) - (float)AVG(UserTokStats.user_tok_freq)*(float)AVG(UserTokStats.user_tok_freq);
                user_freq_stdev   = org.apache.pig.piggybank.evaluation.math.SQRT((float)user_freq_var);
                
                -- global token frequency stats (taken over ALL users)
                global_freq_sum    = (float)SUM(UserTokStats.user_tok_freq);
                global_freq_avg    = (float)(global_freq_sum / (float)$N_USERS);
                global_freq_avg_sq = (float)(global_freq_sum / (float)$N_USERS) * (float)(global_freq_sum / (float)$N_USERS);
                global_freq_var    = ((float)SUM(UserTokStats.user_tok_freq_sq) / (float)$N_USERS) - (float)global_freq_avg_sq;
                global_freq_stdev  = org.apache.pig.piggybank.evaluation.math.SQRT((float)global_freq_var);
                
                tot_tok_usages     = SUM(UserTokStats.num_user_tok_usages) ;
                dispersion         = (float)1.0 - ((float)global_freq_stdev / ( (float)global_freq_avg * (float)$SQRT_OF_N_USERS_MINUS_1 ));
                tok_freq_ppb       = ((float)tot_tok_usages / (float)$TOT_USAGES_AS_DOUBLE)*(float)1000000000.0;
                
                GENERATE
                        group                    AS tok,
                        tot_tok_usages           AS tot_tok_usages,    -- total times THIS tok has been spoken
                        COUNT(UserTokStats)      AS range:             long,  -- total number of people who spoke this tok at least once
                        (float)user_freq_avg     AS user_freq_avg:     float,
                        (float)user_freq_stdev   AS user_freq_stdev:   float,
                        (float)global_freq_avg   AS global_freq_avg:   float, -- average of the frequencies at which this tok is spoken
                        (float)global_freq_stdev AS global_freq_stdev: float, -- standard deviation of the frequencies at which this tok is spoken
                        (float)dispersion        AS dispersion:        float, -- dispersion (see below)
                        (float)tok_freq_ppb      AS tok_freq_ppb:      float  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
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
