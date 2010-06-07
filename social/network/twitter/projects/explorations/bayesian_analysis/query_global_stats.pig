%default STATS '/data/sn/tw/fixd/word/global_word_stats'
%default OUT   '/tmp/sampled_global_stats'
        
stats    = LOAD '$STATS' AS (tok:chararray, tot_tok_usages:long, range:long, user_freq_avg:float, user_freq_stdev:float, gfa:float, gfstdv:float, disp:float, gfppb:float);
cutstats = FOREACH stats GENERATE tok, user_freq_avg, (user_freq_avg*(1.0 - user_freq_avg)/(user_freq_stdev*user_freq_stdev)) - 1.0 AS concentration;
filtered = FILTER cutstats BY tok MATCHES '.*(\\bdata\\b|\\bnematode\\b|\\bcoprolite\\b|\\bhello\\b|\\bdogma\\b|\\btwttr\\b).*';

rmf $OUT;
STORE filtered INTO '$OUT';
