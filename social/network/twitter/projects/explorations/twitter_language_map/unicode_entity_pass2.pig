Edges = LOAD '/tmp/unicode_colloc/uniq_pairs' AS (e1: int, e2: int, freq: int);

Interesting = FILTER Edges BY freq > 3 ;

STORE Interesting INTO '/tmp/unicode_colloc/uniq_pairs_gt_3';
