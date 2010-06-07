%default TWROOT  '/data/sn/tw/fixd/objects'
%default TWWORDS '/data/sn/tw/fixd/word'
%default HOOD    '/data/sn/tw/cool/infochimps_hood'
%default HOODU   '/data/sn/tw/cool/infochimps_hood_u'
-- To avoid a huge # of tiny output files, and for downstream efficiency,
-- we sort jobs' outputs. These give the number of reducers to use for
-- files that are in general tiny (< 200MB), medium (< 2GB), or larger
%default PARALLEL_TINY  1
%default PARALLEL_MED   1
%default PARALLEL_LARGE 1

-- --
-- -- Target user set
-- --
-- ids_and_names_n01   = LOAD '$HOOD/ids_and_names_n01' AS (user_id_or_name: chararray);
-- 
-- --
-- -- Input data
-- --
-- 
-- UserWordStats = LOAD '$TWWORDS/user_word_bag_with_stats' AS (tok:chararray,
--   user:chararray, num_user_tok_usages: long, tot_user_usages: long,
--   user_tok_freq_ppb: double, vocab: long, tot_tok_usages: long, range: long,
--   user_freq_avg: double, user_freq_stdev: double, global_freq_avg: double,
--   global_freq_stdev: double, dispersion: double, tok_freq_ppb: double);
-- 
-- -- ===========================================================================
-- --
-- -- Word uses in n0+n1
-- --
-- 
-- user_word_stats_n01_j = JOIN    UserWordStats  BY user, ids_and_names_n01 BY user_id_or_name using 'replicated';
-- user_word_stats_n01_f = FOREACH user_word_stats_n01_j GENERATE tok, user, num_user_tok_usages, tot_user_usages, user_tok_freq_ppb, vocab, tot_tok_usages, range, user_freq_avg, user_freq_stdev, global_freq_avg, global_freq_stdev, dispersion, tok_freq_ppb ;

user_word_stats_n01_f = LOAD '$HOODU/user_word_stats_n01' AS (tok:chararray,
  user:chararray, num_user_tok_usages: long, tot_user_usages: long,
  user_tok_freq_ppb: double, vocab: long, tot_tok_usages: long, range: long,
  user_freq_avg: double, user_freq_stdev: double, global_freq_avg: double,
  global_freq_stdev: double, dispersion: double, tok_freq_ppb: double);

user_word_stats_n01   = ORDER user_word_stats_n01_f BY user PARALLEL $PARALLEL_LARGE ;

-- Store n0+n1 word uses
rmf                             $HOOD/user_word_stats_n01 ;
STORE user_word_stats_n01 INTO '$HOOD/user_word_stats_n01';
