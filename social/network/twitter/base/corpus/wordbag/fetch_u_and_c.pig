word_stats    = LOAD '$STATS' AS (tok:chararray, tot_tok_usages:long, range:long, tok_freq_avg:double, tok_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
word_stats_fg = FOREACH word_stats GENERATE tok_freq_ppb, tok_freq_ppb*tok_freq_ppb AS tok_freq_ppb_sq;
word_stats_g  = GROUP word_stats_fg ALL;
u_and_c       = FOREACH word_stats_g
                {
                  -- var(tok_freq_ppb) = AVG(tok_freq_ppb^2) - AVG(tok_freq_ppb)^2
                  var = (double)SUM(word_stats_fg.tok_freq_ppb_sq)/(double)SIZE(word_stats_fg) - (double)AVG(word_stats_fg.tok_freq_ppb)*AVG(word_stats_fg.tok_freq_ppb);
                  c   = AVG(word_stats_fg.tok_freq_ppb)*(1.0 - AVG(word_stats_fg.tok_freq_ppb))/var - 1.0;
                  GENERATE
                    AVG(word_stats_fg.tok_freq_ppb) AS u_prior,
                    c AS c_prior
                  ;
                };
DUMP u_and_c;
