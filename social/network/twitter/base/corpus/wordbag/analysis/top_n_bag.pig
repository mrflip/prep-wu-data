%default BIGRPH  '/data/terms/tdidf/bip_graph'
%default WORDBAG '/data/terms/tdidf/wordbag'
%default N      5
        
bigraph    = LOAD '$BIGRPH' AS (user_id:long, term:chararray, weight:float);
bigraph_g  = GROUP bigraph BY user_id;
bigraph_fg = FOREACH bigraph_g {
               ordered = ORDER bigraph BY weight DESC;
               top_n   = LIMIT ordered $N;
               GENERATE group AS user_id, top_n.(term, weight);
             };

rmf $WORDBAG;
STORE bigraph_fg INTO '$WORDBAG';
