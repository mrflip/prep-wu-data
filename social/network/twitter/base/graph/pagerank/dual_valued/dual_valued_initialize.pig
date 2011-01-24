--
-- Take output of the multigraph assembler and initialize both the
-- follow and atsign graphs for pagerank calculation at the same time.
--
edges     = LOAD '$MULTI' AS (multi_edge:chararray, user_a:int, user_b:int, a_fo_b:int, b_fo_a:int, me_o:int, me_i:int, re_o:int, re_i:int, rt_o:int, rt_i:int);
edges_cut = FOREACH edges GENERATE user_a, user_b, a_fo_b, (me_o + re_o + rt_o) AS at_o;
edges_g   = GROUP edges_cut BY user_a;
adj_list  = FOREACH edges_g GENERATE group, 1.0f AS init_fo_rank, 1.0f AS init_me_rank, edges_cut.(user_b, a_fo_b, at_o);

STORE adj_list INTO '$OUT';
