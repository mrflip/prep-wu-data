%default N 100

twitter_user_id = LOAD '$TWUID'   AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);

mapping    = FOREACH twitter_user_id GENERATE uid AS user_id, sn AS screen_name; 
bigraph    = LOAD '$BIGRPH' AS (user_id:long, term:chararray, weight:float);
bigraph_g  = GROUP bigraph BY user_id;
bigraph_fg = FOREACH bigraph_g {
               ordered = ORDER bigraph BY weight DESC;
               top_n   = LIMIT ordered $N;
               GENERATE
                 group                AS user_id,
                 top_n.(term, weight) AS wordbag;
             };

with_sn = JOIN bigraph_fg BY user_id, mapping BY user_id USING 'replicated';
flat    = FOREACH with_sn GENERATE
            mapping::screen_name AS screen_name,
            mapping::user_id     AS user_id,
            bigraph_fg::wordbag  AS wordbag
          ;

STORE flat INTO '$WORDBAG';
