%default NETWORK     'a_follows_b-processed.tsv'
%default OUT_CLIQUE  'seinfeld_n1_clique.tsv'
%default USER        'jerry'
links    = LOAD '$NETWORK' AS (node_a:chararray, node_b:chararray);

-- Extract all nodes in the in or out 1-neighborhood
n1_links  = FILTER links BY (node_a == '$USER') OR (node_b == '$USER');
n1_nodes1 = FOREACH n1_links GENERATE node_a AS node;
n1_nodes2 = FOREACH n1_links GENERATE node_b AS node;
n1_nodes3 = UNION n1_nodes1, n1_nodes2;
n1_nodes  = FILTER (DISTINCT n1_nodes3) BY (node != '$USER');

-- -- Extract all nodes in the in-2 and out-2 nbrhoods
-- n2_out      = JOIN n1_nodes BY node, links BY node_a;
-- n2_out_flat = FOREACH n2_out GENERATE node_b AS node;
-- n2_in       = JOIN links BY node_b, n1_nodes by node;
-- n2_in_flat  = FOREACH n2_in GENERATE node_a AS node;
-- n2_inout    = UNION n2_out_flat, n2_in_flat;
-- n2_nodes    = FILTER (DISTINCT n2_inout) BY (node != '$USER');
-- 
-- -- Intersection of n1 and n2 nodes
-- n1_plus_n2 = UNION n1_nodes, n2_nodes;
-- grouped    = GROUP n1_plus_n2 BY node;
-- counts     = FOREACH grouped GENERATE group AS node, COUNT(n1_plus_n2) AS num;
-- filtered   = FILTER counts BY num >= 2;
-- intersect  = FOREACH filtered GENERATE node;
-- 
-- -- n1_clique is (intersect(n1,n2) U n0_nodes) ?
-- rmf $ATTRS;
-- STORE intersect INTO '$ATTRS';
