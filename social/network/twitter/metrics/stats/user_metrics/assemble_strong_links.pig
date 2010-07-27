weighted_multi_edge = LOAD '$EDGE'   AS (user_a_id:long, user_b_id:long, weight:float);
twitter_user_id     = LOAD '$TW_UID' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);

mapping = FOREACH twitter_user_id GENERATE uid, sn;
grouped = GROUP weighted_multi_edge BY user_a_id;
flat    = FOREACH grouped
          {
              ordered = ORDER weighted_multi_edge BY weight DESC;
              top_100 = LIMIT ordered 100;
              GENERATE
                  group               AS uid,
                  top_100.(user_b_id, weight) AS top_100
              ;
          };

joined = JOIN mapping BY uid FULL OUTER, flat BY uid;
out    = FOREACH joined
         {
             uid = ( mapping::uid IS NOT NULL ? mapping::uid : flat::uid );
             GENERATE
                 uid           AS uid,
                 mapping::sn   AS sn,
                 flat::top_100 AS top_100
             ;
         };

rmf $OUT;
STORE out INTO '$OUT';
