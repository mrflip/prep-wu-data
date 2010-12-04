-- Create trstrank dataset via a join

twitter_user_id  = LOAD '$TW_UID'       AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, is_full:int, health:chararray); -- may need to read from cassandra
pagerank_with_tq = LOAD '$RANK_WITH_TQ' AS (uid:long, rank:float, tq:float);

mapping          = FOREACH twitter_user_id  GENERATE uid, sn;
trstrank_j       = JOIN mapping BY uid RIGHT OUTER, pagerank_with_tq BY uid; -- return every pagerank record with or without screen_name
trstrank         = FOREACH trstrank_j GENERATE
                     mapping::sn                AS sn,
                     pagerank_with_tq::uid      AS uid,
                     pagerank_with_tq::rank     AS rank,
                     (int)pagerank_with_tq::tq  AS tq:int -- cast to an integer here
                   ;

STORE trstrank INTO '$OUT'; -- [screen_name, user_id, trstrank, tq] 
