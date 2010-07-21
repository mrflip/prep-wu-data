REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;
%default WORDBAG '/data/sn/tw/fixd/word/user_word_bag_with_stats'
%default TOKTAB  '/data/sn/tw/fixd/word/typical_token_table'
%default STATS   '/data/sn/tw/fixd/word/outcome'
        
user_stats  = LOAD '$WORDBAG' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq_ppb:double, vocab:long, tot_tok_usages:long, range:long, user_freq_avg:double, user_freq_stdev:double, global_freq_avg:double, global_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
token_table = LOAD '$TOKTAB'  AS (tok:chararray, c_prior:float, u_prior:float);
joined      = JOIN token_table BY tok, user_stats BY tok;
adjusted    = FOREACH joined
              {
                  c_post     = token_table::c_prior + user_stats::tot_user_usages;
                  u_post     = (token_table::c_prior*token_table::u_prior + user_stats::num_user_tok_usages)/(token_table::c_prior + user_stats::tot_user_usages);
                  prior_stdv = org.apache.pig.piggybank.evaluation.math.SQRT(token_table::u_prior*(1.0 - token_table::u_prior)/(token_table::c_prior + 1.0));
                  z_score    = (u_post - u_prior)/prior_stdv;
                  GENERATE
                      token_table::tok AS tok,
                      user_stats::uid  AS uid,
                      z_score          AS z_score
                  ;
              };

rmf $STATS;
STORE adjusted INTO '$STATS';
