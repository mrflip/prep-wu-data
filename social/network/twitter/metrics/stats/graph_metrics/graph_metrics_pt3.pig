%default  REDUCERS 88
%default  MULTI_EDGE_AND_USER_FILE 'fixd/tw/graph/multi_edge_and_user'
%default  USER_GRAPH_METRICS_FILE  'fixd/tw/graph/user_graph_metrics'

MultiEdgeAndUser_1 = LOAD '$MULTI_EDGE_AND_USER_FILE' AS (
  rsrc:                 chararray,
  src:          	long,
  dest:         	long,
  fo_out:       	long,
  fo_in:        	long,
  
  re_out:       	long,
  re_in:        	long,
  
  at_out:       	long,
  at_in:        	long,
  at_out_with:  	long,
  at_in_with:   	long,
  --
  rt_out:       	long,
  rt_in:        	long,
  rt_out_with:  	long,
  rt_in_with:   	long,
  --
  fv_out:       	long,
  fv_in:        	long,
  fv_out_with:  	long,
  fv_in_with:   	long,
  any_out_with: 	long,
  any_in_with:  	long,
  all_out_with: 	long,
  all_in_with:  	long,
  --
  scraped_at:           long,
  screen_name:          chararray,
  protected:            long,
  followers_count:      long,
  friends_count:        long,
  statuses_count:       long,
  favourites_count:     long,
  created_at:           long,
  sid:                  long
  );

mg0 = FOREACH MultiEdgeAndUser_1 GENERATE
  rsrc, src, dest, fo_out, fo_in, re_out, re_in, at_out, at_in, at_out_with,
  at_in_with, rt_out, rt_in, rt_out_with, rt_in_with, fv_out, fv_in,
  fv_out_with, fv_in_with, any_out_with, any_in_with, all_out_with, all_in_with,
  scraped_at, screen_name, protected, followers_count, friends_count,
  statuses_count, favourites_count, created_at, sid,
  ( (fo_out == 1) ? ((double)statuses_count  / (double)(scraped_at - created_at)) : 0.0 ) AS efflux:double,
  ( (fo_out == 1) ? followers_count : 0L ) AS followers_followers_count:long,
  ( (fo_out == 1) ? friends_count   : 0L ) AS followers_friends_count:long
  ;

mg1 = GROUP mg0 BY src ;

UserGraphMetrics_0 = FOREACH mg1 GENERATE
    'conversation_metrics'       AS rsrc:         chararray,
    group                        AS id:           long,
    COUNT(mg0)                   AS any_with:     long,
    (long)SUM(mg0.any_out_with)  AS any_out_with: long,
    (long)SUM(mg0.any_in_with)   AS any_in_with:  long,
    --
    (long)SUM(mg0.re_out)        AS re_out:       long,
    (long)SUM(mg0.re_in)         AS re_in:        long,
    --
    (long)SUM(mg0.at_out)        AS at_out:       long,
    (long)SUM(mg0.at_in)         AS at_in:        long,
    (long)SUM(mg0.at_out_with)   AS at_out_with:  long,
    (long)SUM(mg0.at_in_with)    AS at_in_with:   long,
    
    (long)SUM(mg0.rt_out)        AS rt_out:       long,
    (long)SUM(mg0.rt_in)         AS rt_in:        long,
    (long)SUM(mg0.rt_out_with)   AS rt_out_with:  long,
    (long)SUM(mg0.rt_in_with)    AS rt_in_with:   long,
    --
    (long)SUM(mg0.fv_out)        AS fv_out:       long,
    (long)SUM(mg0.fv_in)         AS fv_in:        long,
    (long)SUM(mg0.fv_out_with)   AS fv_out_with:  long,
    (long)SUM(mg0.fv_in_with)    AS fv_in_with:   long,
    --
    AVG(mg0.efflux)              AS avg_influx_of_friends:	double,
    SUM(mg0.efflux)              AS influx:       double,
    (long)AVG( (mg0.fo_out == 1) ? mg0.followers_followers_count : 0.0 ) AS followers_followers_avg:  long,
    (long)SUM(mg0.followers_followers_count) AS followers_followers_tot:long,
    (long)AVG( (mg0.fo_out == 1) ? mg0.followers_friends_count : 0.0 ) AS followers_friends_avg:  long,
    (long)SUM(mg0.followers_friends_count)   AS followers_friends_tot:long
    ;

UserGraphMetrics_1 = ORDER UserGraphMetrics_0 BY re_in DESC, rt_in DESC;

rmf                             $USER_GRAPH_METRICS_FILE  ;
STORE UserGraphMetrics_1  INTO '$USER_GRAPH_METRICS_FILE' ;
-- User_Graph_Metrics   = LOAD '$USER_GRAPH_METRICS_FILE' AS
--   ( id: int, 
--     n_fo_out: int,   n_fo_in: int,   
--     n_re_out: int,   n_re_in: int,   n_re_out_with: int, n_re_in_with: int, 
--     n_at_out: int,   n_at_in: int,   n_at_out_with: int, n_at_in_with: int, 
--     n_rt_out: int,  n_rt_in: int,  
--     n_fv_out: int, n_fv_in: int, n_fv_out_with: int, n_fv_in_with: int );

-- StrongLinks = FILTER MultiEdge BY (at_out > 0) OR (rt_out > 0) OR (fv_out > 0);
-- mStr2 = GROUP  StrongLinks BY src ;
-- UserStrongLinks = FOREACH mStr2 GENERATE
--   group                AS id,
--   (int)COUNT(StrongLinks) AS n_strong_out:int,
--   StrongLinks.(dest, fo_out, fo_in, re_out, re_in, at_out, at_in, rt_out, rt_in, fv_out, fv_in);
-- DESCRIBE UserStrongLinks ;
-- rm                          twtr/metrics/user_strong_links ;
-- STORE UserStrongLinks INTO 'twtr/metrics/user_strong_links';
-- UserStrongLinks     = LOAD 'twtr/metrics/user_strong_links' AS
--   (id: int, n_strong_out: int,
--   StrongLinks: {dest: int,fo_out: int,fo_in: int,re_out: int,re_in: int,at_out: int,at_in: int,rt_out: int,rt_in: int,fv_out: int,fv_in: int}
--   );
