%default TERMS '/data/sn/tw/fixd/wordbag-sampled/user_toks-many'
%default TRAIN '/data/sn/tw/fixd/wordbag-sampled/term_trials'
        
terms    = LOAD '$TERMS' AS (term:chararray, uid:long, s_t:int, d_u:int, r_t:float, r_t_sq:float, vocab:int);        
terms_c  = FOREACH terms GENERATE term, s_t, d_u; -- term, term appearances, trials (each row is an observation)
terms_g  = GROUP terms_c BY term;                 -- gather all observations of a single term
terms_fg = FOREACH terms_g {
             terms_f = FILTER terms_c BY d_u >= 50; -- throw out observations with too few trials (doc. size too small)
             terms_l = LIMIT terms_f 10000;         -- keep distribution a reasonable size (hard to plot otherwise)
             GENERATE
               group AS term,
               terms_l.(s_t, d_u) AS terms_l
             ;
           };

terms_f = FILTER terms_fg BY COUNT(terms_l) > 2; -- throw out all terms observed less than twice, not words
        
rmf $TRAIN
STORE terms_f INTO '$TRAIN';        
