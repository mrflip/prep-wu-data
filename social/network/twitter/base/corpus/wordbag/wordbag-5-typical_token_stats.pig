
%default WORDBAG_ROOT     '/data/sn/tw/fixd/wordbag';

-- values found from one off job to determine "typical token", see notes
%default C_PRIOR '978.67'
%default U_PRIOR '1.2494E-6'
  
user_tok_user_stats     = LOAD '$WORDBAG_ROOT/user_tok_user_stats' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
        
typical_token_stats_0  = FOREACH user_tok_user_stats GENERATE tok, num_user_tok_usages, tot_user_usages;
typical_token_stats_g  = GROUP   typical_token_stats_0 BY tok;
typical_token_stats    = FOREACH typical_token_stats_g
  {
  n_measure = SUM(typical_token_stats_0.tot_user_usages);
  s_success = SUM(typical_token_stats_0.num_user_tok_usages);
  c_tok     = (double)$C_PRIOR + (double)n_measure;
  u_tok     = (double)($C_PRIOR*(double)$U_PRIOR + (double)s_success)/((double)$C_PRIOR + (double)n_measure);
  GENERATE
    group  AS tok,
    c_tok AS c_tok,
    u_tok AS u_tok
    ;
};

rmf                     $WORDBAG_ROOT/typical_token_stats
STORE typical_token_stats INTO '$WORDBAG_ROOT/typical_token_stats';
typical_token_stats     = LOAD '$WORDBAG_ROOT/typical_token_stats' AS (tok:chararray, c_tok:double, u_tok:double);
