--
-- Take users table, output of pagerank, and result of percentile ranking
-- and smash them together.
--
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default IDS      '/data/sn/tw/fixd/objects/twitter_user_id'
%default FO_PRCNT '/data/sn/tw/fixd/pagerank/a_follows_b_percentile'
%default AT_PRCNT '/data/sn/tw/fixd/pagerank/a_atsigns_b_percentile'
%default FINAL    '/data/sn/tw/fixd/pagerank/trstrank'        

user_id  = LOAD '$IDS'      AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
follow   = LOAD '$FO_PRCNT' AS (uid:long, rank:float, prcnt:float);
atsign   = LOAD '$AT_PRCNT' AS (uid:long, rank:float, prcnt:float);         
mapping  = FOREACH user_id  GENERATE uid, sn;

together = JOIN atsign BY uid FULL OUTER, follow BY uid;
intermed = FOREACH together
           {
               atrank   = (atsign::rank  IS NOT NULL ? atsign::rank  : follow::rank);
               forank   = (follow::rank  IS NOT NULL ? follow::rank  : atrank );
               at_tq    = (atsign::prcnt IS NOT NULL ? atsign::prcnt : follow::prcnt);
               fo_tq    = (follow::prcnt IS NOT NULL ? follow::prcnt : at_tq );
               uid      = (atsign::uid   IS NOT NULL ? atsign::uid   : follow::uid);
               trstrank = (atrank  + forank )/2.0;
               tq       = (at_tq   + fo_tq  )/2.0;               
               GENERATE
                   uid      AS uid,
                   trstrank AS trstrank,
                   tq       AS tq
               ;
           };

joined   = JOIN intermed BY uid FULL OUTER, mapping BY uid;
flat     = FOREACH joined
           {
               uid = (mapping::uid IS NOT NULL ? mapping::uid : intermed::uid);
               GENERATE
                   mapping::sn        AS sn,
                   mapping::uid       AS uid,
                   intermed::trstrank AS trstrank,
                   (int)intermed::tq  AS tq:int
               ;
           }

out      = FILTER flat BY sn != '0';

rmf $FINAL;
STORE out INTO '$FINAL'; -- [screen_name, user_id, trstrank, tq] 
