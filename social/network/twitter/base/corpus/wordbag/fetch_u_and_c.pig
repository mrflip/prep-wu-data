word_stats    = LOAD '$STATS' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
word_stats_fg = FOREACH word_stats GENERATE tok_freq_ppb, tok_freq_ppb*tok_freq_ppb AS tok_freq_ppb_sq;
word_stats_g  = GROUP word_stats_fg ALL;
u_and_c       = FOREACH word_stats_g
                {
                  u   = AVG(word_stats_fg.tok_freq_ppb);
                  -- var(tok_freq_ppb) = AVG(tok_freq_ppb^2) - AVG(tok_freq_ppb)^2
                  var = (double)SUM(word_stats_fg.tok_freq_ppb_sq)/(double)SIZE(word_stats_fg) - (double)u*u;
                  c   = u*(1.0 - u)/var - 1.0;
                  GENERATE
                    u AS u_prior,
                    c AS c_prior
                  ;
                };
DUMP u_and_c;
