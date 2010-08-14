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
-- map input records to first mr job    = tot usages
-- reduce input groups in second mr job = tot users

-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=600' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-3-tok_stats.pig

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';

%default N_USERS          '3.8002003E7';       -- total users in the sample **AS A DOUBLE**
%default SQRT_N_USERS_M1  '6163.576465581395';
%default TOT_USAGES       '1.6501474834E10';   -- total non-distinct usages **AS A DOUBLE**

-- 3.8002003E7,6163.576465581395,1.6501474834E10
  
usage_user_stats = LOAD '$WORDBAG_ROOT/usage_user_stats' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);

tok_stats_g      = GROUP usage_user_stats BY tok;
tok_stats        = FOREACH tok_stats_g  { -- for every token, generate...
  
  -- global token frequency stats (taken over ALL users)
  tok_freq_sum    = (double)SUM(usage_user_stats.user_tok_freq);
  tok_freq_avg    = (double)(tok_freq_sum / $N_USERS);
  tok_freq_avg_sq = (double)(tok_freq_sum / $N_USERS) * (double)(tok_freq_sum / $N_USERS);
  tok_freq_var    = ((double)SUM(usage_user_stats.user_tok_freq_sq) / $N_USERS) - tok_freq_avg_sq;
  tok_freq_stdev  = org.apache.pig.piggybank.evaluation.math.SQRT(tok_freq_var);

  tot_tok_usages     = SUM(usage_user_stats.num_user_tok_usages);
  dispersion         = (double)1.0 - ((double)tok_freq_stdev / ( (double)tok_freq_avg * $SQRT_N_USERS_M1 ));
  tok_freq_ppb       = ((double)tot_tok_usages / (double)tot_usages)*(double)1000000000.0;

  GENERATE
    group                     AS tok,
    tot_tok_usages            AS tot_tok_usages,            -- total times THIS tok has been spoken
    COUNT(usage_user_stats)   AS range:             long,   -- total number of people who spoke this tok at least once
    (double)tok_freq_avg      AS tok_freq_avg:      double, -- average of the frequencies at which this tok is spoken
    (double)tok_freq_stdev    AS tok_freq_stdev:    double, -- standard deviation of the frequencies at which this tok is spoken
    (double)dispersion        AS dispersion:        double, -- dispersion (see below)
    (double)tok_freq_ppb      AS tok_freq_ppb:      double  -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
    ;
  };

rmf                   $WORDBAG_ROOT/tok_stats
STORE tok_stats INTO '$WORDBAG_ROOT/tok_stats';
tok_stats     = LOAD '$WORDBAG_ROOT/tok_stats' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);


