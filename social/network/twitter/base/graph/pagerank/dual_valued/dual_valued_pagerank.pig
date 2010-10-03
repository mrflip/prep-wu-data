--
-- Take output of dual valued intializer and compute both pagerank
-- types at the same time.
--
%default CURR_ITER_FILE 'pagerank_graph_000'
%default NEXT_ITER_FILE 'pagerank_graph_001'
%default DAMP   0.95f

pr_list = LOAD '$CURR_ITER_FILE' AS (v1:int, fo_rank:float, at_rank:float, links:bag { link:tuple (v2:int, a_fo_b:float, at_o:float) });        
pr_f    = FOREACH pr_list {
            n_links = (float)COUNT(links);
            GENERATE
              FLATTEN(links)  AS (v, a_fo_b, at_o),
              fo_rank/n_links AS raw_fo_share,
              at_rank/n_links AS raw_at_share
            ;
          };

pr_s    = FOREACH pr_f {
            -- at_signing more than once adds no more value, for now
            at_val = (at_o > 0.0f ? 1.0f : 0.0f);
            GENERATE v AS v, raw_fo_share*a_fo_b AS fo_share, raw_at_share*at_val AS at_share;
          }
                  
pr_l    = FOREACH pr_list GENERATE v1 AS v, links;                  
rcvd    = COGROUP pr_l BY v INNER, pr_s BY v;
rcvd_fg = FOREACH rcvd {
            raw_fo_rank = (float)SUM(pr_s.fo_share);
            raw_at_rank = (float)SUM(pr_s.at_share);
            -- treat the case that a node has no in links                   
            damped_fo_rank = ((raw_fo_rank IS NOT NULL AND raw_fo_rank > 1.0e-12f) ? raw_fo_rank*$DAMP + 1.0f - $DAMP : 0.0f);
            damped_at_rank = ((raw_at_rank IS NOT NULL AND raw_at_rank > 1.0e-12f) ? raw_at_rank*$DAMP + 1.0f - $DAMP : 0.0f);
            GENERATE
              group          AS v,
              damped_fo_rank AS fo_rank,
              damped_at_rank AS at_rank,      
              FLATTEN(pr_l.links) -- hack, should only be one bag, unbag it
            ;
          };

rmf $NEXT_ITER_FILE 
STORE rcvd_fg INTO '$NEXT_ITER_FILE';
