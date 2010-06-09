%default STATS '/data/sn/tw/fixd/word/global_word_stats'
%default OUT   '/data/sn/tw/fixd/sample/sampled_global_stats'
        
stats    = LOAD '$STATS' AS (tok:chararray, tot_tok_usages:long, range:long, user_freq_avg:float, user_freq_stdev:float, gfa:float, gfstdv:float, disp:float, gfppb:float);
cutstats = FOREACH stats GENERATE tok, gfppb;
sampled  = SAMPLE cutstats 0.01;

rmf $OUT;
STORE sampled INTO '$OUT';
