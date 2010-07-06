-- params (override or leave as default)

--   IDS              = path to id mapping table
--   RANK             = path to pagerank and id
--   TRSTME           = path to final output date for trst me app

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;

%default IDS    '/data/sn/tw/fixd/users_table'
%default RANK   '/data/sn/tw/pagerank/a_follows_b'
%default TRSTME '/data/sn/tw/pagerank/a_follows_b_with_sn'

mapping = LOAD '$IDS' AS (sn:chararray, uid:long, sid:long);
rank    = LOAD '$PAGERANK' AS (uid:long, pr:float);
joined  = JOIN rank BY uid, mapping BY id;
flat    = FOREACH joined GENERATE
                mapping::sn AS sn,
                rank::uid   AS uid,
                rank::pr    AS pr
          ;

grouped  = GROUP flat ALL;
intermed = FOREACH grouped GENERATE flatten(flat), MAX(flat.pr) AS max_pr;
out      = FOREACH intermed GENERATE flat::sn AS sn, flat::uid AS uid, flat::pr AS pr, 10.0*( (float)org.apache.pig.piggybank.evaluation.math.LOG(flat::pr) / (float)org.apache.pig.piggybank.evaluation.math.LOG(max_pr) ) AS scaled; 

rmf $TRSTME;
STORE out INTO '$TRSTME';
