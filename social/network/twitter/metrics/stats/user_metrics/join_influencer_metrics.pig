%default TWOUTIN '/data/sn/tw/fixd/graph/tweet_flux'
%default DEGDIST '/data/sn/tw/fixd/graph/degree_distribution'
%default BREAK   '/data/sn/tw/fixd/graph/tweet_flux_breakdown'
%default IDS      '/data/sn/tw/fixd/objects/twitter_user_id'

user_id  = LOAD '$IDS'      AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
deg_dist = LOAD '$DEGDIST'  AS (uid:long, fo_o:long, fo_i:long, at_o:long, at_i:long, re_o:long, re_i:long, rt_o:long, rt_i:long);
tw_dist  = LOAD '$TWOUTIN'  AS (uid:long, tw_o:long, tw_in:long, tw_out:long);

joined   = JOIN user_id BY uid, deg_dist BY uid, tw_dist BY uid;
out      = FOREACH joined GENERATE
                user_id::sn       AS sn,
                tw_dist::uid      AS uid,
                tw_dist::sn       AS sn,
                tw_dist::crat     AS crat,
                tw_dist::tw_out   AS tw_out,
                tw_dist::tw_in    AS tw_in,
                deg_dist::rep_out AS rep_out,
                deg_dist::rep_in  AS rep_in,
                deg_dist::ats_out AS ats_out,
                deg_dist::ats_in  AS ats_in,
                deg_dist::ret_out AS ret_out,
                deg_dist::ret_in  AS ret_in,
                deg_dist::fav_out AS fav_out,
                deg_dist::fav_in  AS fav_in
           ;

rmf $METRICS;
STORE out INTO '$METRICS';
