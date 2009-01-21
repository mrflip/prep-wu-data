-- Load init_load.pig first please

--
-- Prepare data with
--
-- dest=meta/lang/collocs ;
-- hdp-rm -r $dest ;
-- ./analysis/lang/entity_pairs.rb --go --mode=collocations fixd/flattened/tweet.tsv $dest
-- 

-- ===========================================================================
--
-- Load extracted entities
--
EntityDist 	= LOAD 'meta/lang/entities_dist' AS (entity:  int, 		 count: int) ;
Collocs 	= LOAD 'meta/lang/collocs' 	 AS (entity1: int, entity2: int, count: int) ; 
UserEntities 	= LOAD 'meta/lang/user_entities' AS (user_id: int, entity:  int, count: int) ;  

-- Map    input bytes    	 9,760,668,914	10   GB
-- Map    output bytes   	78,959,783,259  79   GB
-- Reduce output bytes   	   370,081,309   .37 GB
-- Map    input records  	    50,723,858  tweets
-- Map    output records 	 6,220,079,211  pairs to accumulate
-- Reduce output records            16,092,362  unique pairs with count


-- ===========================================================================
--
-- Distribution of pair counts.  Eliminating pairs that have been seen together
-- five or fewer times leaves only 7.6M out of 16M; eliminating pairs occurring
-- 100 or fewer times leaves 385k, and 10,000 or fewer leaves 65k nodes
--
--
-- How many entity pairs are there for each count?
CollocsCountDist_1 	= FOREACH Collocs GENERATE count ;
CollocsCountDist_2 	= GROUP CollocsCountDist_1 BY count ;
CollocsCountDist 	= FOREACH CollocsCountDist_2 GENERATE group AS entities_count, COUNT(CollocsCountDist_1) AS num ;
STORE CollocsCountDist    INTO 'meta/lang/collocs_count_dist';
CollocsCountDist 	= LOAD 'meta/lang/collocs_count_dist' AS (entities_count: int,num: long);

-- 
-- pair 	num. w/		 num w/this	num w/this
-- freq.	this freq   	  or fewer	 or more
--     1	3,913,779	 3,913,779	12,178,583
--     2	1,965,754	 5,879,533	10,212,829
--     3	1,150,450	 7,029,983	 9,062,379
--     4	  846,737	 7,876,720	 8,215,642
--     5	  611,406	 8,488,126	 7,604,236
--     6	  508,199	 8,996,325	 7,096,037
--     7	  404,098	 9,400,423	 6,691,939
--     8	  347,419	 9,747,842	 6,344,520
--     9	  294,202	10,042,044	 6,050,318
--    10	  259,566	10,301,610	 5,790,752
--    14	  167,163	11,083,039	 5,009,323
--    17	  128,195	11,503,180	 4,589,182
--    21	   97,298	11,932,910	 4,159,452
--    22	   91,049	12,023,959	 4,068,403
--    25	   76,546	12,267,752	 3,824,610
--    50	   29,247	13,413,475	 2,678,887
--   100	   10,788	14,284,471	 1,807,891
--  1000	      297	15,706,908	   385,454
-- 10000	        5	16,027,554	    64,808
-- 20000	        1	16,056,134	    36,228
--
-- I'll cull any pair occurring fewer than 22 times, leaving us with a
-- healthy-sized 4M node network to play with. (at 4M rows this can also be
-- filtered easily on local disk using tail)
CollocsDump_1 		= FILTER Collocs BY count >= 22 ;
CollocsDump 		= ORDER  CollocsDump_1 BY count DESC ;
STORE CollocsDump         INTO 'meta/lang/collocs_22up';
CollocsDump     	= LOAD 'meta/lang/collocs_22up' AS  (entity1: int, entity2: int, count: int) ; 

-- ===========================================================================
--
-- Get geocoordinates for each entity
Coords   	= LOAD 'meta/geo/users' 	AS (user_id:int, lat: float, lng: float, lat_chunk:int, lng_chunk:int) ;
EntityCoords_1 	= JOIN UserEntities BY user_id, Coords BY user_id PARALLEL 100;
EntityCoords_2 	= FOREACH EntityCoords_1 GENERATE entity AS entity, Coords::lat_chunk AS lat_chunk, Coords::lng_chunk AS lng_chunk, count AS count;
EntityCoords_3  = GROUP EntityCoords_2 BY (entity, lat_chunk, lng_chunk) PARALLEL 100;
EntityCoords 	= FOREACH EntityCoords_3 GENERATE group.entity AS entity, group.lat_chunk AS lat_chunk, group.lng_chunk AS lng_chunk, SUM(EntityCoords_2.count) AS count;
STORE EntityCoords   INTO 'meta/lang/entity_geos' ;
Entity_Coords   = LOAD 'meta/lang/entity_geos' AS (entity: int,lat_chunk: int,lng_chunk: int,count: long);


-- Get timezones for each entity's users
TZs 		= FOREACH UserProfiles GENERATE user_id, utc_offset;
EntityTZs_1 	= JOIN UserEntities BY user_id, TZs BY user_id PARALLEL 100;
EntityTZs_2 	= FOREACH EntityTZs_1 GENERATE entity AS entity, TZs::user_id AS user_id, TZs::utc_offset AS utc_offset, count AS count;
EntityTZs_3     = GROUP EntityTZs_2 BY (entity, utc_offset) PARALLEL 100;
EntityTZs 	= FOREACH EntityTZs_3 GENERATE group.entity AS entity, group.utc_offset AS utc_offset, SUM(EntityTZs_2.count) AS count;
STORE EntityTZs   INTO 'meta/lang/entity_tzs' ;
Entity_TZs      = LOAD 'meta/lang/entity_tzs' AS (entity: int,utc_offset: int,count: long);

-- ============================================================================
-- 
-- Pair users with entities
--
-- OBSOLETE
--
-- UserEntities_0  = FOREACH CollocAll GENERATE user_id, entity;
-- UserEntities_1	= GROUP UserEntities_0 BY (user_id, entity);
-- UserEntities_2  = FOREACH UserEntities_1 GENERATE group.user_id AS user_id, group.entity AS entity, COUNT(UserEntities_0.entity) AS count;
