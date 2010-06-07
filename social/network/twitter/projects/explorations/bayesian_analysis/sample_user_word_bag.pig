%default WORDBAG '/data/sn/tw/fixd/word/user_word_bag'
%default OUT     '/tmp/sampled_word_bag'
        
wordbag  = LOAD '$WORDBAG' AS (tok:chararray, user_id:chararray, num_user_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double);
cutbag   = FOREACH wordbag GENERATE tok, num_user_usages, tot_user_usages;
filtered = FILTER cutbag BY tok MATCHES '.*(\\bdata\\b|\\bnematode\\b|\\bcoprolite\\b|\\bhello\\b|\\bdogma\\b|\\btwttr\\b).*';
sampled  = SAMPLE filtered 0.1;
 
rmf $OUT;
STORE sampled INTO '$OUT'; 
