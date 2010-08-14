-- the io.sort.mb here can be turned down -- set it to ~20% higher than the avg map output size. (map, not combiner)
-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=800 -Dio.sort.record.percent=0.4' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-4-tot_tok_stats.pig

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

tok_stats     = LOAD '$WORDBAG_ROOT/tok_stats' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);

tot_tok_stats_fg  = FOREACH tok_stats GENERATE tok_freq_ppb, tok_freq_ppb*tok_freq_ppb AS tok_freq_ppb_sq;
tot_tok_stats_g   = GROUP   tot_tok_stats_fg ALL PARALLEL 1;
tot_tok_stats     = FOREACH tot_tok_stats_g GENERATE
  SUM(tot_tok_stats_fg.tok_freq_ppb)    AS sum_freq_ppb,
  SUM(tot_tok_stats_fg.tok_freq_ppb_sq) AS sum_freq_ppb_sq,
  COUNT(tot_tok_stats_fg)               AS num_toks
  ;
  

-- tot_tok_stats    = FOREACH tot_tok_stats_g
--   {
--   -- var(tok_freq_ppb) = AVG(tok_freq_ppb^2) - AVG(tok_freq_ppb)^2
--   var = (double)SUM(tot_tok_stats_fg.tok_freq_ppb_sq)/(double)SIZE(tot_tok_stats_fg) - (double)AVG(tot_tok_stats_fg.tok_freq_ppb)*AVG(tot_tok_stats_fg.tok_freq_ppb);
--   c_tok   = AVG(tot_tok_stats_fg.tok_freq_ppb)*(1.0 - AVG(tot_tok_stats_fg.tok_freq_ppb))/var - 1.0;
--   GENERATE
--     AVG(tot_tok_stats_fg.tok_freq_ppb) AS u_tok,
--     c_tok AS c_tok
--     ;
-- };

rmf                       $WORDBAG_ROOT/tot_tok_stats
STORE tot_tok_stats INTO '$WORDBAG_ROOT/tot_tok_stats';
tot_tok_stats     = LOAD '$WORDBAG_ROOT/tot_tok_stats' AS (u_tok:double, c_tok:double);

DUMP tot_tok_stats;
