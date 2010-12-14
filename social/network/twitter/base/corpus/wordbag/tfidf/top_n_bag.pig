-- Params:
--   N_TOKS,  number of tokens to place in bag, eg 100
--   TWUID,   path to twitter_user_id table
--   BIGRPH,  path to output of tdidf.pig (user,token,weight)
--   WORDBAG, path to output
--
-- Command:
-- pig -p N_TOKS=100 -p TWUID=/path/to/twitter_user_id -p BIGRPH=/output/of/tfidf -p WORDBAG=/path/to/output top_n_bag.pig
--


twitter_user_id = LOAD '$TWUID'   AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);

mapping    = FOREACH twitter_user_id GENERATE uid AS user_id, sn AS screen_name; 
bigraph    = LOAD '$BIGRPH' AS (user_id:long, term:chararray, weight:float);
bigraph_g  = GROUP bigraph BY user_id;
bigraph_fg = FOREACH bigraph_g {
               ordered = ORDER bigraph BY weight DESC;
               top_n   = LIMIT ordered $N_TOKS;
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
