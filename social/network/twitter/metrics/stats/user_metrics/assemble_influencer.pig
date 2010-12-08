twitter_user_id     = LOAD '$TWUID'   AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
degree_distribution = LOAD '$DEGDIST' AS (uid:long, fo_o:long, fo_i:long, at_o:long, at_i:long, re_o:long, re_i:long, rt_o:long, rt_i:long);
tweet_flux          = LOAD '$FLUX'    AS (uid:long, tw_o:long, tw_i:long);
break_down          = LOAD '$BREAK'   AS (uid:long, ms_tw_o:long, hsh_o:long, sm_o:long, url_o:long); -- measured tw_o
pagerank            = LOAD '$RANK'    AS (uid:long, fo_rank:float, at_rank:float, fo_i:long);

cut_rank = FOREACH rank GENERATE uid, fo_rank, at_rank;
cut_id   = FOREACH twitter_user_id GENERATE uid, sn, followers, friends, crat;

with_deg = JOIN cut_id BY uid FULL OUTER, degree_distribution BY uid;
first    = FOREACH with_deg {
             uid = ( cut_id::uid IS NOT NULL ? cut_id::uid : degree_distribution::uid );
             GENERATE
               cut_id::sn                AS sn,        -- twitter user screen name
               uid                       AS uid,       -- twitter user id
               cut_id::crat              AS crat,      -- twitter reported user profile created at date
               cut_id::followers         AS followers, -- twitter reported follows in
               cut_id::friends           AS friends,   -- twitter reported follows out
               degree_distribution::fo_o AS fo_o,      -- observed follows out
               degree_distribution::fo_i AS fo_i,      -- observed follows in
               degree_distribution::at_o AS at_o,      -- observed mentions out
               degree_distribution::at_i AS at_i,      -- observed mentions in
               degree_distribution::re_o AS re_o,      -- observed replies out
               degree_distribution::re_i AS re_i,      -- observed replies in
               degree_distribution::rt_o AS rt_o,      -- observed retweets out
               degree_distribution::rt_i AS rt_i       -- observed retweets in
             ;
           };

with_twdist = JOIN first BY uid FULL OUTER, tweet_flux BY uid;
second      = FOREACH with_twdist {
                uid = ( first::uid IS NOT NULL ? first::uid : tweet_flux::uid );
                GENERATE
                  first::sn        AS sn,
                  uid              AS uid,
                  first::crat      AS crat,
                  first::followers AS followers,
                  first::friends   AS friends,
                  first::fo_o      AS fo_o,
                  first::fo_i      AS fo_i,
                  first::at_o      AS at_o,
                  first::at_i      AS at_i,
                  first::re_o      AS re_o,
                  first::re_i      AS re_i,
                  first::rt_o      AS rt_o,
                  first::rt_i      AS rt_i,
                  tweet_flux::tw_o AS tw_o, -- twitter reported tweets out
                  tweet_flux::tw_i AS tw_i  -- (basically) twitter reported tweets in (joined with a_follows_b to get)
                ;
              };

with_brk = JOIN second BY uid FULL OUTER, break_down BY uid;
third    = FOREACH with_brk {
             uid = ( second::uid IS NOT NULL ? second::uid : break_down::uid );
             GENERATE
               second::sn          AS sn,            
               uid                 AS uid,           
               second::crat        AS crat,          
               second::followers   AS followers,
               second::friends     AS friends,
               second::fo_o        AS fo_o,          
               second::fo_i        AS fo_i,          
               second::at_o        AS at_o,          
               second::at_i        AS at_i,          
               second::re_o        AS re_o,          
               second::re_i        AS re_i,          
               second::rt_o        AS rt_o,          
               second::rt_i        AS rt_i,          
               second::tw_o        AS tw_o,          
               second::tw_i        AS tw_i,
               break_down::ms_tw_o AS ms_tw_o, -- observed tweets out
               break_down::hsh_o   AS hsh_o,   -- observed hashtags out
               break_down::sm_o    AS sm_o,    -- observed smileys out
               break_down::url_o   AS url_o    -- observed urls out
             ;
           };

with_rank = JOIN third BY uid FULL OUTER, cut_rank BY uid;
fourth    = FOREACH with_rank {
              uid = ( third::uid IS NOT NULL ? third::uid : cut_rank::uid );
              GENERATE
                third::sn         AS sn,            
                uid               AS uid,           
                third::crat       AS crat,          
                third::followers  AS followers,
                third::friends    AS friends,
                third::fo_o       AS fo_o,          
                third::fo_i       AS fo_i,          
                third::at_o       AS at_o,          
                third::at_i       AS at_i,          
                third::re_o       AS re_o,          
                third::re_i       AS re_i,          
                third::rt_o       AS rt_o,          
                third::rt_i       AS rt_i,          
                third::tw_o       AS tw_o,          
                third::tw_i       AS tw_i,          
                third::ms_tw_o    AS ms_tw_o,
                third::hsh_o      AS hsh_o,         
                third::sm_o       AS sm_o,          
                third::url_o      AS url_o,
                cut_rank::at_rank AS at_tr, -- calculated at rank based on retweets, mentions, and replies
                cut_rank::fo_rank AS fo_tr  -- calculated fo rank based on followers and friends
              ;
          };

out = FILTER fourth BY sn != '0';
STORE out INTO '$METRICS';

-- infl = LOAD '$METRICS' AS (sn:chararray, uid:long, crat:long, followers:long, friends:);
