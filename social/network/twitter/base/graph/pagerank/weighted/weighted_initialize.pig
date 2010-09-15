%default EDGES   'sample_graph.tsv'
%default PRPGRPH 'pagerank_graph_000'
        
edges    = LOAD '$EDGES' AS (v1:int, v2:int, fo_sy:float, at_sy:float, weight:float);

-- Turn the arbitrary weights into probabilities
edges_g  = GROUP edges BY v1;
edges_l  = FOREACH edges_g GENERATE group AS v1, FLATTEN(edges.(v2, fo_sy, at_sy, weight)) AS (v2, fo_sy, at_sy, weight), (float)SUM(edges.weight) AS weight_integral;
pairs    = FOREACH edges_l GENERATE v1, v2, fo_sy, at_sy, weight/weight_integral AS weight;
--

v2_edges = FOREACH pairs GENERATE v2;
v2_uniq  = DISTINCT v2_edges;
edges_cg = COGROUP pairs BY v1, v2_uniq BY v2;
adj_list = FOREACH edges_cg {
             links = (IsEmpty(pairs.v2) ? {(999999999,0.0f,0.0f,0.0f)} : pairs.(v2, fo_sy, at_sy, weight));
             GENERATE
               group      AS v,
               1.0f       AS fo_rank,
               1.0f       AS at_rank,
               1.0f       AS w_rank,
               links      AS links
             ;
           };

rmf $PRPGRPH;
STORE adj_list INTO '$PRPGRPH';
