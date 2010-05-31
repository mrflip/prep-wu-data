%default NETWORK     'a_follows_b-processed.tsv'
%default OUT_n1x     'seinfeld_n1x.tsv'
%default OUT_CLIQUE  'seinfeld_clique_n1x_n1x.tsv'
%default N0_SEED     'jerry'
a_follows_b    = LOAD '$NETWORK' AS (node_a:chararray, node_b:chararray);

-- PIG_OPTS=-Dmapred.local.dir=/tmp pig -x local
-- may need to sudo chgrp -R admin /mnt*/hadoop/mapred/local ; sudo chmod -R g+rwX /mnt*/hadoop/mapred/local

-- Extract all edges that originate or terminate on the seed (n0)
e1_edges    = FILTER a_follows_b BY (node_a == '$N0_SEED') OR (node_b == '$N0_SEED');

--
-- From e1_edges, find all nodes in the in or out 1-neighborhood
-- (the nodes at radius 1 from our seed)
--
n1_out      = FOREACH e1_edges GENERATE node_a AS node;
n1_in       = FOREACH e1_edges GENERATE node_b AS node;
n1x_nodes_u  = UNION n1_out, n1_in;
n1x_nodes_1  = FILTER   n1x_nodes_u BY (node != '$N0_SEED') ;
n1x_nodes    = DISTINCT n1x_nodes_1 ;

-- Save the set of nodes at radius-1 
-- rmf   $OUT_n1x
-- STORE n1x_nodes_d INTO '$OUT_n1x' ;
n1x_nodes   = LOAD        '$OUT_n1x' AS (node:chararray);

-- Find all edges that originate in n1
e2o_edges_n1x_out_j  = JOIN a_follows_b BY node_a, n1x_nodes BY node using 'replicated';
e2o_edges_n1x_out    = FOREACH e2o_edges_n1x_out_j GENERATE node_a, node_b;

-- Among those edges, find those that terminate in n1 as well
clique_n1x_n1x_j      = JOIN e2o_edges_n1x_out BY node_b, n1_nodes BY node using 'replicated';
clique_n1x_n1x        = FOREACH clique_n1x_n1x_j GENERATE node_a, node_b;

-- Save the result
rmf                       $OUT_CLIQUE;
STORE clique_n1x_n1x INTO '$OUT_CLIQUE';
