weighted_multi_edge = LOAD '$WEDGES' AS (user_a_id:long, user_b_id:long, fo_sy:int, at_sy:int, weight:float);
twitter_user_id     = LOAD '$TWUID'   AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        

mapping = FOREACH twitter_user_id GENERATE uid, sn;
grouped = COGROUP weighted_multi_edge BY user_a_id, mapping BY uid;
flat    = FOREACH grouped {
            ordered = ORDER weighted_multi_edge BY weight DESC;
            top_100 = LIMIT ordered 100;
            GENERATE
              group                        AS user_id,
              FLATTEN(mapping.sn)          AS screen_name, --flatten is funny here since there should only be one match on the cogroup
              top_100.(user_b_id, weight)  AS top_100
            ;
          };

STORE flat INTO '$STRLNKS';
