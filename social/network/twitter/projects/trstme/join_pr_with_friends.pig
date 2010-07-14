--
-- Get pr and num followers
--
%default IDS         '/data/sn/tw/fixd/objects/twitter_user_id'
%default TRSTME      '/data/sn/tw/fixd/pagerank/a_follows_b_with_sn'
%default PR_V_FOLLOW '/data/sn/tw/fixd/pagerank/a_follows_b_v_followers'

user_id = LOAD '$IDS'    AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
trstme  = LOAD '$TRSTME' AS (sn:chararray, uid:long, pr:float, scaled:float);
rank    = FOREACH trstme  GENERATE sn, pr, scaled;
follow  = FOREACH user_id GENERATE sn, followers;
joined  = JOIN rank BY sn, follow BY sn;
flat    = FOREACH joined GENERATE
                rank::pr          AS pr,
                rank::scaled      AS scaled,
                follow::followers AS followers
          ;

rmf $PR_V_FOLLOW;
STORE flat INTO '$PR_V_FOLLOW';
