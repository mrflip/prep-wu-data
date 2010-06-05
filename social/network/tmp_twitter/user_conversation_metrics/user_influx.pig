-- AFollowsB           = LOAD 'fixd/tw/out/a_follows_b' AS (
AFollowsB           = LOAD 'ripd/com.tw/sampled/parsed/com.twitter3/a_follows_b.tsv' AS (
   rsrc: chararray, user_a_id: long, user_b_id: long);

-- ===========================================================================
--
-- Load Graph
-- 
-- Take a subset of the attributes
AFollowsB = FOREACH AFollowsB GENERATE user_a_id AS src, user_b_id AS dest;
-- Take a subset of the attributes
UserMetrics_1 = FOREACH UserMetrics GENERATE id AS dest,
  tw_day,
  tw_day_recent
  ;

-- ===========================================================================
--
-- Adorn edges with info
--

-- Join edge and info 
-- this is the right way round: hold the single edge in memory,
-- adorn it with the stream of incoming id's
Influx_0 = JOIN AFollowsB BY dest, UserMetrics_1 BY dest;
-- Project back into flat objects
Influx_1 = FOREACH Influx_0 GENERATE src,  AFollowsB::dest AS dest,
  tw_day,  tw_day_recent
  ;

-- ===========================================================================
--
-- Characterize 1-neighborhood.
--

-- Group on source node
Influx_2 = GROUP Influx_1 BY src;
-- Project
Influx = FOREACH Influx_2 GENERATE
  'influx'				AS rsrc:chararray,
  group                                 AS src, 
  SUM(Influx_1.tw_day)  	        AS influx,
  SUM(Influx_1.tw_day_recent)        	AS influx_recent
  ;
-- Store!
rmf                   twnew/metrics/influx ;
STORE Influx    INTO 'twnew/metrics/influx' ; 
Influx        = LOAD 'twnew/metrics/influx' AS
  (src: int, influx:float, influx_recent: float);
