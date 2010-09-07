--
-- Generate training distributions for bayesian classifier
--
%default TERMS '/data/sn/tw/fixd/wordbag-sampled/user_toks-many'
%default TRAIN '/data/sn/tw/fixd/wordbag-sampled/training_distributions'
        
terms    = LOAD '$TERMS' AS (term:chararray, uid:long, s_t:int, d_u:int, r_t:float, r_t_sq:float, vocab:int);        
terms_c  = FOREACH terms GENERATE term, s_t, d_u;
terms_g  = GROUP terms_c BY term;
terms_fg = FOREACH terms_g {
             terms_f = FILTER terms_c BY d_u >= 50; -- throw out observations with too few trials
             terms_l = LIMIT terms_f 10000;         -- keep distribution a reasonable size
             S_t = SUM(terms_l.s_t);                -- total usages of term t
             GENERATE
               group AS term,
               S_t   AS S_t,
               terms_l.(s_t, d_u) AS terms_l
             ;
           };
terms_f = FILTER terms_fg BY (S_t > 2) AND COUNT(terms_l) > 5; -- throw out all terms observed less than twice, not words
        
rmf $TRAIN
STORE terms_f INTO '$TRAIN';        
