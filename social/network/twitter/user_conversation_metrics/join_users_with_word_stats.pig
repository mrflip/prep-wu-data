-- desired output:
--
-- [user_id, word, A(word), B(word), ... ]
--
-- where A, B, etc are stats on the word
--


%default WORDBAG       '/data/sn/tw/fixd/word/user_word_bag';            --input location
%default WORDSTATS     '/data/sn/tw/fixd/word/global_word_stats';        --input location
%default USERWORDS_OUT '/data/sn/tw/fixd/word/user_word_bag_with_stats'; --output location

UserTokStats = LOAD '$WORDBAG' AS (
                        tok:                 chararray,
                        user_id:             chararray, --could be screen name OR long id
                        num_user_tok_usages: long,
                        tot_user_usages:     long,
                        user_tok_freq:       double,
                        user_tok_freq_sq:    double,
                        vocab:               long
               );

GlobalTokStats = LOAD '$WORDSTATS' AS (
                        tok:               chararray, --
                        tot_tok_usages:    long,      -- total times THIS tok has been spoken
                        range:             long,      -- total number of people who spoke this tok at least once
                        user_freq_avg:     double,
                        user_freq_stdev:   double,
                        global_freq_avg:   double,     -- average of the frequencies at which this tok is spoken
                        global_freq_stdev: double,     -- standard deviation of the frequencies at which this tok is spoken
                        dispersion:        double,     -- dispersion (see below)
                        tok_freq_ppb:      double      -- total times THIS tok has been spoken out of the total toks that have EVER been spoken
                        );


UserAndGlobalTokStats_1 = JOIN UserTokStats BY tok, GlobalTokStats BY tok ;

UserAndGlobalTokStats = FOREACH UserAndGlobalTokStats_1 GENERATE
  GlobalTokStats::tok AS tok,
  user_id,
  num_user_tok_usages,
  tot_user_usages,
  user_tok_freq * 1000000000.0 AS user_tok_freq_ppb,
  vocab,
  tot_tok_usages,
  range,
  user_freq_avg,
  user_freq_stdev,
  global_freq_avg,
  global_freq_stdev,
  dispersion,
  tok_freq_ppb
  ;

rmf                        $USERWORDS_OUT;
STORE UserAndGlobalTokStats INTO '$USERWORDS_OUT';
