-- map input records to first mr job    = tot usages
-- reduce input groups in second mr job = tot users

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;
-- REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;

%default WORDBAG                 '/data/sn/tw/fixd/word/user_word_bag';     --input location
%default WORDSTATS               '/data/sn/tw/fixd/word/global_word_stats'; --output location
%default SQRT_OF_N_USERS_MINUS_1 '1009.0342';
%default N_USERS                 '1018151.0';  -- total users in the sample
%default TOT_USAGES_AS_DOUBLE    '16231264.0'; -- total non-distinct usages

user_stats = LOAD '$WORDBAG' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
grouped    = GROUP user_stats BY tok;
tok_stats  = FOREACH grouped -- for every token, generate...
             {
                 -- user token frequency stats (taken over participating users only)
                 user_freq_avg     = AVG(user_stats.user_tok_freq);
                 user_freq_var     = (double)AVG(user_stats.user_tok_freq_sq) - (double)AVG(user_stats.user_tok_freq)*(double)AVG(user_stats.user_tok_freq);
                 user_freq_stdev   = org.apache.pig.piggybank.evaluation.math.SQRT((double)user_freq_var);
                
                 -- global token frequency stats (taken over ALL users)
                 global_freq_sum    = (double)SUM(user_stats.user_tok_freq);
                 global_freq_avg    = (double)(global_freq_sum / (double)$N_USERS);
                 global_freq_avg_sq = (double)(global_freq_sum / (double)$N_USERS) * (double)(global_freq_sum / (double)$N_USERS);
                 global_freq_var    = ((double)SUM(user_stats.user_tok_freq_sq) / (double)$N_USERS) - (double)global_freq_avg_sq;
                 global_freq_stdev  = org.apache.pig.piggybank.evaluation.math.SQRT((double)global_freq_var);
                
                 tot_tok_usages     = SUM(user_stats.num_user_tok_usages);
                 dispersion         = (double)1.0 - ((double)global_freq_stdev / ( (double)global_freq_avg * (double)$SQRT_OF_N_USERS_MINUS_1 ));
                 tok_freq_ppb       = ((double)tot_tok_usages / (double)$TOT_USAGES_AS_DOUBLE)*(double)1000000000.0;
                
                 GENERATE
                     group                     AS tok,
                     tot_tok_usages            AS tot_tok_usages,           -- total times THIS tok has been spoken
                     COUNT(user_stats)         AS range:             long,  -- total number of people who spoke this tok at least once
                     (double)user_freq_avg     AS user_freq_avg:     double, -- usage frequency of this token for participating pop.
                     (double)user_freq_stdev   AS user_freq_stdev:   double, -- usage stdev for this token for participating pop.
                     (double)global_freq_avg   AS global_freq_avg:   double, -- average of the frequencies at which this tok is spoken
                     (double)global_freq_stdev AS global_freq_stdev: double, -- standard deviation of the frequencies at which this tok is spoken
                     (double)dispersion        AS dispersion:        double, -- dispersion (see below)
                     (double)tok_freq_ppb      AS tok_freq_ppb:      double  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
                 ;
             };

rmf $WORDSTATS;
STORE tok_stats INTO '$WORDSTATS';
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
