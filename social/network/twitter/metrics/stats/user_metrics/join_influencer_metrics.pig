%default TWOUTIN '/data/sn/tw/fixd/graph/tweets_out_in'
%default DEGDIST '/data/sn/tw/fixd/graph/degree_distribution'
%default METRICS '/data/sn/tw/fixd/graph/raw_user_metrics'
        
deg_dist = LOAD '$DEGDIST' AS (uid:long, rep_out:long, rep_in:long, ats_out:long, ats_in:long, ret_out:long, ret_in:long, fav_out:long, fav_in:long);
tw_dist  = LOAD '$TWOUTIN' AS (uid:long, tw_in:long, tw_out:long, crat:long);

joined   = JOIN tw_dist BY uid, deg_dist BY uid;
out      = FOREACH joined GENERATE
                tw_dist::uid      AS uid,
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
