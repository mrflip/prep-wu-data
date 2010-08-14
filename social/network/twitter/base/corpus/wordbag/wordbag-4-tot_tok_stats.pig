--
--
-- n_tokens, s_f, s_f_sq, a_f, a_f_sq = [ 65_524_511, 1e9 ,1.8e15, 15.26, 2.77e7 ]
--
-- Usage:
-- PIG_OPTS='-Dio.sort.record.percent=0.2' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/wordbag-4-tot_tok_stats.pig
--

%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

tok_stats     = LOAD '$WORDBAG_ROOT/tok_stats' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);

tot_tok_stats_fg  = FOREACH tok_stats GENERATE tok_freq_ppb, tok_freq_ppb*tok_freq_ppb AS tok_freq_ppb_sq;
tot_tok_stats_g   = GROUP   tot_tok_stats_fg ALL PARALLEL 1;
tot_tok_stats_agg = FOREACH tot_tok_stats_g GENERATE
  COUNT(tot_tok_stats_fg)               AS num_toks,
  SUM(tot_tok_stats_fg.tok_freq_ppb)    AS sum_freq_ppb,
  SUM(tot_tok_stats_fg.tok_freq_ppb_sq) AS sum_freq_ppb_sq,
  AVG(tot_tok_stats_fg.tok_freq_ppb)    AS avg_freq_ppb,
  AVG(tot_tok_stats_fg.tok_freq_ppb_sq) AS avg_freq_ppb_sq
  ;
  
tot_tok_stats    = FOREACH tot_tok_stats_agg
  {
  -- variance = AVG(freq^2) - AVG(freq)^2
  var_freq_ppb = avg_freq_ppb_sq - (avg_freq_ppb * avg_freq_ppb);
  std_freq_ppb = org.apache.pig.piggybank.evaluation.math.SQRT(var_freq_ppb);
  c_tok    = (avg_freq_ppb)*(1.0 - avg_freq_ppb)/var_freq_ppb - 1.0;
  GENERATE
    num_toks,
    sum_freq_ppb,
    sum_freq_ppb_sq,
    avg_freq_ppb,
    avg_freq_ppb_sq,
    std_freq_ppb AS std_freq_ppb,
    avg_freq_ppb AS u_tok,
    c_tok        AS c_tok
    ;
};

rmf                       $WORDBAG_ROOT/tot_tok_stats
STORE tot_tok_stats INTO '$WORDBAG_ROOT/tot_tok_stats';
tot_tok_stats     = LOAD '$WORDBAG_ROOT/tot_tok_stats' AS (
  num_toks:long, sum_freq_ppb:double, sum_freq_ppb_sq:double, avg_freq_ppb:double, avg_freq_ppb_sq:double,
  std_freq_ppb:double, u_tok:double, c_tok:double
  );

DUMP tot_tok_stats;
