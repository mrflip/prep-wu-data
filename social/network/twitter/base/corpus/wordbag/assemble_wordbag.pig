REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;
%default WORDBAG       '/data/sn/tw/fixd/word/user_word_bag'
%default WORDSTATS     '/data/sn/tw/fixd/word/global_word_stats'
%default TOKTAB        '/data/sn/tw/fixd/word/typical_token_table'        
%default USERWORDS_OUT '/data/sn/tw/fixd/word/user_word_bag_with_stats'

user_stats   = LOAD '$WORDBAG'   AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);        
global_stats = LOAD '$WORDSTATS' AS (tok:chararray, tot_tok_usages:long, range:long, user_freq_avg:double, user_freq_stdev:double, global_freq_avg:double, global_freq_stdev:double, dispersion:double, tok_freq_ppb:double);
tok_table    = LOAD '$TOKTAB'    AS (tok:chararray, c_prior:float, u_prior:float);

joined_stats = JOIN tok_table BY tok, user_stats BY tok, global_stats BY tok;
final_stats  = FOREACH joined_stats
               {
                   -- calculate z score between users implied distribution and 'typical' distr.
                   c_post     = tok_table::c_prior + user_stats::tot_user_usages;
                   u_post     = (tok_table::c_prior*tok_table::u_prior + user_stats::num_user_tok_usages)/(tok_table::c_prior + user_stats::tot_user_usages);
                   prior_stdv = org.apache.pig.piggybank.evaluation.math.SQRT(tok_table::u_prior*(1.0 - tok_table::u_prior)/(tok_table::c_prior + 1.0));
                   z_score    = (u_post - u_prior)/prior_stdv;
                   GENERATE
                       global_stats::tok                        AS tok,
                       user_stats::uid                          AS uid,
                       z_score                                  AS z_score,
                       user_stats::num_user_tok_usages          AS num_user_tok_usages,
                       user_stats::tot_user_usages              AS tot_user_usages,
                       user_stats::user_tok_freq * 1000000000.0 AS user_tok_freq_ppb,
                       user_stats::vocab                        AS vocab,
                       global_stats::tot_tok_usages             AS tot_tok_usages,
                       global_stats::range                      AS range,
                       global_stats::user_freq_avg              AS user_freq_avg,
                       global_stats::user_freq_stdev            AS user_freq_stdev,
                       global_stats::global_freq_avg            AS global_freq_avg,
                       global_stats::global_freq_stdev          AS global_freq_stdev,
                       global_stats::dispersion                 AS dispersion,
                       global_stats::tok_freq_ppb               AS tok_freq_ppb
                   ;
               };

rmf $USERWORDS_OUT;
STORE final_stats INTO '$USERWORDS_OUT';
