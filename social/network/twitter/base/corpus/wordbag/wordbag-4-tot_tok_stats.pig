-- the io.sort.mb here can be turned down -- set it to ~20% higher than the avg map output size. (map, not combiner)
-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=800 -Dio.sort.record.percent=0.2' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-4-tot_tok_stats.pig

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';
  
tok_stats     = LOAD '$WORDBAG_ROOT/tok_stats' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);

-- I then used R to get avg(tok_freq_ppb) and var(tok_freq_ppb)
-- then calculate for U_PRIOR and a formula to get C_PRIOR from 
-- This should be fine since global_token_stats is small enough to hdp-catd that column into a file
-- getting U_PRIOR and C_PRIOR is kind of a one-off job
-- then, if all of that goes well, and it should, theres the typical token table
-- pig -p C_PRIOR=! -p U_PRIOR=! -p WORDBAG=/tmp/user_word_bag -p TOKTAB=/tmp/typical_token_table /home/jacob/Programming/infochimps-data/social/network/twitter/base/corpus/wordbag/typical_token_table.pig

tot_tok_stats_0 = FOREACH tok_stats GENERATE tot_tok_usages, range, tok_freq_avg, tok_freq_ppb;
tot_tok_stats_g = GROUP   tot_tok_stats_0 ALL PARALLEL 1; 
tot_tok_stats   = FOREACH tot_tok_stats_g GENERATE
  avg,
  stdev,
  c_prior,
  u_prior
  ;

rmf                   $WORDBAG_ROOT/tot_tok_stats
STORE tok_stats INTO '$WORDBAG_ROOT/tot_tok_stats';
tok_stats     = LOAD '$WORDBAG_ROOT/tot_tok_stats' AS ();
