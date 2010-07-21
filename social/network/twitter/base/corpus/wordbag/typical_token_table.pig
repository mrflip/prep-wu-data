%default WORDBAG '/data/sn/tw/fixd/word/user_word_bag'
%default TOKTAB  '/data/sn/tw/fixd/word/typical_token_table'
-- values found from one off job to determine "typical token", see notes
%default C_PRIOR '978.67'
%default U_PRIOR '1.2494E-6'
        
user_stats = LOAD '$WORDBAG' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);        
cut_stats  = FOREACH user_stats GENERATE tok, num_user_tok_usages, tot_user_usages;
grouped    = GROUP cut_stats BY tok;
token_table = FOREACH grouped
              {
                  n_measure = SUM(cut_stats.tot_user_usages);
                  s_success = SUM(cut_stats.num_user_tok_usages);
                  c_post    = $C_PRIOR + n_measure;
                  u_post    = ($C_PRIOR*$U_PRIOR + s_success)/($C_PRIOR + n_measure);
                  GENERATE
                      group  AS tok,
                      c_post AS c_post,
                      u_post AS u_post
                  ;
              };

rmf $TOKTAB;
STORE token_table INTO '$TOKTAB';
