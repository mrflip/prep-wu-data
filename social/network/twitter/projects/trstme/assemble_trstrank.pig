--
-- Take users table, output of pagerank, and result of percentile ranking
-- and smash them together.
--

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default IDS      '/data/sn/tw/fixd/objects/twitter_user_id'
%default FO_PRCNT '/data/sn/tw/fixd/pagerank/a_follows_b_percentile'
%default AT_PRCNT '/data/sn/tw/fixd/pageranl/a_atsigns_b_percentile'
%default FINAL    '/data/sn/tw/fixd/pagerank/trstrank'        

user_id  = LOAD '$IDS'      AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
follow   = LOAD '$FO_PRCNT' AS (uid:long, rank:float, prcnt:float);
atsign   = LOAD '$AT_PRCNT' AS (uid:long, rank:float, prcnt:float);         
mapping  = FOREACH user_id  GENERATE uid, sn;
        
joined   = JOIN follow BY uid, atsign BY uid, mapping BY uid;
flat     = FOREACH joined
           {
               trstrank = (atsign::rank  + follow::rank )/2.0;
               tq       = (atsign::prcnt + follow::prcnt)/2.0;
               GENERATE
                   mapping::sn  AS sn,
                   mapping::uid AS uid,
                   trstrank     AS trstrank,
                   tq           AS tq
               ;
           };

rmf $FINAL;
STORE flat INTO '$FINAL'; -- [screen_name, user_id, trstrank, tq] 
