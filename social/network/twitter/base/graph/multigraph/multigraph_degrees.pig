--
-- Take the output of the multigraph script to generate:
--
-- [user_id, fo_o, fo_i, at_o, at_i, re_o, re_i, rt_o, rt_i] 
--
%default DEGREE '/data/sn/tw/fixd/graph/degree_distribution'
        
graph   = LOAD '$GRAPH' AS (rsrc:chararray, user_a_id:long, user_b_id:long, a_fo_b:int, b_fo_a:int, at_o:long, at_i:long, re_o:long, re_i:long, rt_o:long, rt_i:long); 
grouped = GROUP graph BY user_a_id;
degrees = FOREACH grouped GENERATE
              group             AS uid,
              SUM(graph.a_fo_b) AS fo_o,
              SUM(graph.b_fo_a) AS fo_i,
              SUM(graph.at_o)   AS at_o,
              SUM(graph.at_i)   AS at_i,
              SUM(graph.re_o)   AS re_o,
              SUM(graph.re_i)   AS re_i,
              SUM(graph.rt_o)   AS rt_o,
              SUM(graph.rt_i)   AS rt_i
          ;

rmf $DEGREE;
STORE degrees INTO '$DEGREE';