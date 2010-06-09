%default STATSBAG '/data/sn/tw/fixd/word/user_word_bag_with_stats'
%default OUT      '/data/sn/tw/fixd/sample/sampled_word_bag'
        
wordbag  = LOAD '$STATSBAG' AS
           (
                tok:                 chararray,
                user_id:             chararray,
                num_user_tok_usages: long,
                tot_user_usages:     long,
                user_tok_freq_ppb:   double,
                vocab:               long,
                tot_tok_usages:      long,
                range:               long,
                user_freq_avg:       double,
                user_freq_stdev:     double,
                global_freq_avg:     double,
                global_freq_stdev:   double,
                dispersion:          double,
                tok_freq_ppb:        double
           );

cutbag   = FOREACH wordbag GENERATE tok, user_id, num_user_tok_usages, tot_user_usages, tot_tok_usages;
filtered = FILTER cutbag BY tok MATCHES '.*(\\bdata\\b|\\bthe\\b|\\belectric\\b|\\bcoprolite\\b|\\bhello\\b|\\bdogma\\b).*';
sampled  = SAMPLE filtered 0.01;
 
rmf $OUT;
STORE sampled INTO '$OUT'; 
