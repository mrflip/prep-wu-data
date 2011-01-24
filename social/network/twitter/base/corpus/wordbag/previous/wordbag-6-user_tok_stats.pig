%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

user_tok_user_stats = LOAD '$WORDBAG_ROOT/user_tok_user_stats' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
tok_stats           = LOAD '$WORDBAG_ROOT/tok_stats'           AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double,  tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
typical_token_stats = LOAD '$WORDBAG_ROOT/typical_token_stats' AS (tok:chararray, c_tok:double, u_tok:double);

user_tok_stats_0 = JOIN typical_token_stats BY tok, tok_stats BY tok, user_tok_user_stats BY tok;
user_tok_stats   = FOREACH user_tok_stats_0
  {
  -- calculate z score between users implied distribution and 'typical' distr.
  c_post     = tok_table::c_tok + user_stats::tot_user_usages;
  u_post     = (tok_table::c_tok*tok_table::u_tok + user_stats::num_user_tok_usages)/(tok_table::c_tok + user_stats::tot_user_usages);
  prior_stdv = org.apache.pig.piggybank.evaluation.math.SQRT(tok_table::u_tok*(1.0 - tok_table::u_tok)/(tok_table::c_tok + 1.0));
  z_score    = (u_post - u_tok)/prior_stdv;
  GENERATE
    global_stats::tok                        AS tok,
    user_stats::uid                          AS uid,
    z_score                                  AS z_score,
    c_post                                   AS c_post,
    u_post                                   AS u_post,
    user_stats::num_user_tok_usages          AS num_user_tok_usages,
    user_stats::tot_user_usages              AS tot_user_usages,
    user_stats::user_tok_freq * 1000000000.0 AS user_tok_freq_ppb,
    user_stats::vocab                        AS vocab,
    global_stats::tot_tok_usages             AS tot_tok_usages,
    global_stats::range                      AS range,
    global_stats::tok_freq_avg               AS tok_freq_avg,
    global_stats::tok_freq_stdev             AS tok_freq_stdev,
    global_stats::dispersion                 AS dispersion,
    global_stats::tok_freq_ppb               AS tok_freq_ppb
    ;
  };

rmf                        $WORDBAG_ROOT/user_tok_stats
STORE user_tok_stats INTO '$WORDBAG_ROOT/user_tok_stats';
user_tok_stats     = LOAD '$WORDBAG_ROOT/user_tok_stats' AS (
  tok:chararray, uid:long,
  z_score:double, c_post:double, u_post:double,
  num_user_tok_usages:long, tot_user_usages:long, user_tok_freq_ppb:long, vocab:long,
  tot_tok_usages:long, range:long, tok_freq_avg:double,  tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
