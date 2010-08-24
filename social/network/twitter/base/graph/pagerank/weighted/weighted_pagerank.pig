%default CURR_ITER_FILE 'pagerank_graph_000'
%default NEXT_ITER_FILE 'pagerank_graph_001'
%default DAMP   0.95f

--
-- Here the weight should be a probability
-- 
pr_list = LOAD '$CURR_ITER_FILE' AS (v1:int, rank:float, links:bag { link:tuple (v2:int, weight:float) });
pr_f    = FOREACH pr_list GENERATE FLATTEN(links) AS (v, weight), rank AS raw_rank;
pr_s    = FOREACH pr_f GENERATE v AS v, raw_rank*weight AS share;
pr_l    = FOREACH pr_list GENERATE v1 AS v, links;
rcvd    = COGROUP pr_l BY v INNER, pr_s BY v;
rcvd_fg = FOREACH rcvd {
            raw_rank = (float)SUM(pr_s.share);
            -- treat the case that a node has no in links                   
            damped_rank = ((raw_rank IS NOT NULL AND raw_rank > 1.0e-12f) ? raw_rank*$DAMP + 1.0f - $DAMP : 0.0f);
            GENERATE
              group       AS v,
              damped_rank AS rank,
              FLATTEN(pr_l.links) -- hack, should only be one bag, unbag it
            ;
          };

rmf $NEXT_ITER_FILE 
STORE rcvd_fg INTO '$NEXT_ITER_FILE';
