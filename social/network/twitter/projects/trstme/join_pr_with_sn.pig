-- params (override or leave as default)

--   IDS              = path to id mapping table
--   RANK             = path to pagerank and id
--   TRSTME           = path to final output date for trst me app

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

%default IDS    '/data/sn/tw/fixd/objects/twitter_user_id'
%default RANK   '/data/sn/tw/fixd/pagerank/a_follows_b'
%default TRSTME '/data/sn/tw/fixd/pagerank/a_follows_b_with_sn'

user_id = LOAD '$IDS'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
rank    = LOAD '$RANK' AS (uid:long, pr:float);
mapping = FOREACH user_id GENERATE uid, sn;
joined  = JOIN rank BY uid, mapping BY uid;
flat    = FOREACH joined GENERATE
                mapping::sn AS sn,
                rank::uid   AS uid,
                rank::pr    AS pr
          ;

grouped  = GROUP flat ALL;
intermed = FOREACH grouped GENERATE flatten(flat), MAX(flat.pr) AS max_pr;
out      = FOREACH intermed GENERATE flat::sn AS sn, flat::uid AS uid, flat::pr AS pr, 10.0*( (float)org.apache.pig.piggybank.evaluation.math.LOG(flat::pr + 1.0) / (float)org.apache.pig.piggybank.evaluation.math.LOG(max_pr + 1.0) ) AS scaled; 

rmf $TRSTME;
STORE out INTO '$TRSTME';
