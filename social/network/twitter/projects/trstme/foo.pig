%default TRST '/data/sn/tw/fixd/pagerank/trstrank_20100809'
%default ATS  '/data/sn/tw/rawd/pagerank/a_atsigns_b/pig/pagerank_graph_010'
%default FOS  '/data/sn/tw/rawd/pagerank/a_follows_b/pig/pagerank_graph_010'        
%default OUT  '/data/sn/tw/fixd/pagerank/trstrank_20100809_fixd'

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

follow    = LOAD '$FOS'  AS (uid:long, rank:float, list:chararray);
atsign    = LOAD '$ATS'  AS (uid:long, rank:float, list:chararray);         
trst      = LOAD '$TRST' AS (sn:chararray, uid:long, scaled:float, tq:int);

cut_fo    = FOREACH follow GENERATE uid, rank;
cut_at    = FOREACH atsign GENERATE uid, rank;

group_fo  = GROUP cut_fo ALL;
fo_max    = FOREACH group_fo GENERATE FLATTEN(cut_fo), MAX(cut_fo.rank) AS max_rank;
fo_scaled = FOREACH fo_max
            {
                scaled = 10.0*( (float)org.apache.pig.piggybank.evaluation.math.LOG(cut_fo::rank + 1.0) / (float)org.apache.pig.piggybank.evaluation.math.LOG(max_rank + 1.0) );
                GENERATE
                    cut_fo::uid AS uid,
                    scaled      AS scaled
                ;
            };

group_at  = GROUP cut_at ALL;
at_max    = FOREACH group_at GENERATE FLATTEN(cut_at), MAX(cut_at.rank) AS max_rank;
at_scaled = FOREACH fo_max
            {
                scaled = 10.0*( (float)org.apache.pig.piggybank.evaluation.math.LOG(cut_at::rank + 1.0) / (float)org.apache.pig.piggybank.evaluation.math.LOG(max_rank + 1.0) );
                GENERATE
                    cut_at::uid AS uid,
                    scaled      AS scaled
                ;
            };

full        = JOIN fo_scaled BY uid FULL OUTER, at_scaled BY uid;
full_scaled = FOREACH full
              {
                  atrank   = (at_scaled::scaled  IS NOT NULL ? at_scaled::scaled : fo_scaled::scaled);
                  forank   = (fo_scaled::scaled  IS NOT NULL ? fo_scaled::scaled : at_scaled::scaled);
                  trstrank = (atrank + forank)/2.0;
                  uid      = (at_scaled::uid IS NOT NULL ? at_scaled::uid : fo_scaled::uid);
                  GENERATE
                      uid      AS uid,
                      trstrank AS trstrank
                  ;
              };

outjoin = JOIN full_scaled BY uid FULL OUTER, trst BY uid;
out     = FOREACH outjoin
          {
              uid      = (full_scaled::uid IS NOT NULL ? full_scaled::uid : trst::uid);
              GENERATE
                  trst::sn AS sn,
                  uid      AS uid,
                  full_scaled::trstrank AS trstrank,
                  trst::tq AS tq
              ;
                  
          };

rmf $OUT;
STORE out INTO '$OUT';
