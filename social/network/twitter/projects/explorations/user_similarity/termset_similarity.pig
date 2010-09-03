%default GRAPH 'user_pairs.tsv'
%default SETS  'user_words.tsv'

-- very memory intensive, join wordbags on both sides of a user,user edge        
edges        = LOAD '$GRAPH' AS (user_a_id:int, user_b_id:int);
wordsets     = LOAD '$SETS'  AS (user_id:int, max_usage:int, num_usages:int, max_freq:float, max_freq_sq:float, vocab:int, termset:bag { term_tup:tuple (term:chararray) });
wordsets_c   = FOREACH wordsets GENERATE user_id, termset;
words_lhs    = COGROUP edges BY user_a_id INNER, wordsets_c BY user_id;
words_lhs_fg = FOREACH words_lhs GENERATE FLATTEN(edges) AS (user_a_id, user_b_id), FLATTEN(wordsets_c.termset) AS user_a_words;
words_rhs    = COGROUP words_lhs_fg BY user_b_id INNER, wordsets_c BY user_id;
words_all_fg = FOREACH words_rhs GENERATE FLATTEN(words_lhs_fg) AS (user_a_id, user_b_id, user_a_words), FLATTEN(wordsets_c.termset) AS user_b_words;
-- stream through jaccard similarity function
jac_idx      = STREAM words_all_fg THROUGH `jaccard_index.rb --map`;
DUMP jac_idx;
