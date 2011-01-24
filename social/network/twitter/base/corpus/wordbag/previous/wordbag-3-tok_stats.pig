-- Params:
--   USAGE_FREQS, input data
--   TOKEN_STATS, output data
--
-- ** Explanation of output variables **
--
-- Range is how many people used the word
--
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
--


-- PIG_OPTS='-Dmapred.min.split.size=402653184 -Dio.sort.mb=620 -Dio.sort.record.percent=0.2' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-3-tok_stats.pig

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

user_usage_freqs = LOAD '$USAGE_FREQS' AS (token_text:chararray, user_id:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);  

global_token_stats_g = GROUP user_usage_freqs BY token_text;
global_token_stats   = FOREACH global_token_stats_g {
                         tok_freq_sum    = (double)SUM(user_tok_user_stats.user_tok_freq);
                         tok_freq_avg    = (double)(tok_freq_sum / $N_USERS);
                         tok_freq_avg_sq = (double)(tok_freq_sum / $N_USERS) * (double)(tok_freq_sum / $N_USERS);
                         tok_freq_var    = ((double)SUM(user_tok_user_stats.user_tok_freq_sq) / $N_USERS) - tok_freq_avg_sq;
                         tok_freq_stdev  = org.apache.pig.piggybank.evaluation.math.SQRT(tok_freq_var);
                         tot_tok_usages  = SUM(user_tok_user_stats.num_user_tok_usages);
                         dispersion      = (double)1.0 - ((double)tok_freq_stdev / ( (double)tok_freq_avg * $SQRT_N_USERS_M1 ));
                         tok_freq_ppb    = ((double)tot_tok_usages / $TOT_USAGES)*(double)1000000000.0;

                         GENERATE
                           group                       AS token_text,
                           tot_tok_usages              AS tot_tok_usages: double, -- total times THIS tok has been spoken
                           (double)tok_freq_ppb        AS tok_freq_ppb:   double,  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
                           COUNT(user_usage_freqs)     AS range:          long,    -- total number of people who spoke this tok at least once
                           (double)tok_freq_stdev      AS tok_freq_stdev: double,  -- standard deviation of the frequencies at which this tok is spoken
                           (double)dispersion          AS dispersion:     double,  -- dispersion (see above)
                         ;
                       };

--returns (token_text, tot_tok_usages, tok_freq_ppb, range, tok_freq_stdev, dispersion)

STORE global_token_stats INTO '$TOKEN_STATS';
