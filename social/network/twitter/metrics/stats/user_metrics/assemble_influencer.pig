%default TWOUTIN '/data/sn/tw/fixd/graph/tweet_flux'
%default DEGDIST '/data/sn/tw/fixd/graph/degree_distribution'
%default BREAK   '/data/sn/tw/fixd/graph/tweet_flux_breakdown'
%default ATRANK  '/data/sn/tw/fixd/pagerank/a_atsigns_b_with_fo'
%default FORANK  '/data/sn/tw/fixd/pagerank/a_follows_b_with_fo'        
%default IDS     '/data/sn/tw/fixd/objects/twitter_user_id'
%default METRICS '/data/sn/tw/fixd/influencer_metrics'            

ids      = LOAD '$IDS'      AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
deg_dist = LOAD '$DEGDIST'  AS (uid:long, fo_o:long, fo_i:long, at_o:long, at_i:long, re_o:long, re_i:long, rt_o:long, rt_i:long);
tw_dist  = LOAD '$TWOUTIN'  AS (uid:long, tw_o:long, tw_i:long);
break_dn = LOAD '$BREAK'    AS (uid:long, ms_tw_o:long, hsh_o:long, sm_o:long, url_o:long); -- measured tw_o
at_rank  = LOAD '$ATRANK'   AS (uid:long, followers:long, rank:float);
fo_rank  = LOAD '$FORANK'   AS (uid:long, followers:long, rank:float);        

cut_at   = FOREACH at_rank GENERATE uid, rank;
cut_fo   = FOREACH fo_rank GENERATE uid, rank;
user_id  = FOREACH ids GENERATE uid, sn, followers, crat;
joined   = JOIN user_id BY uid, deg_dist BY uid, tw_dist BY uid, break_dn BY uid, cut_at BY uid, cut_fo BY uid;
flat     = FOREACH joined GENERATE
                'influencer'       AS rsrc,
                user_id::sn        AS sn,
                user_id::uid       AS uid,
                user_id::crat      AS crat,
                user_id::followers AS followers,
                deg_dist::fo_o     AS fo_o,
                deg_dist::fo_i     AS fo_i,
                deg_dist::at_o     AS at_o,
                deg_dist::at_i     AS at_i,
                deg_dist::re_o     AS re_o,
                deg_dist::re_i     AS re_i,
                deg_dist::rt_o     AS rt_o,
                deg_dist::rt_i     AS rt_i,
                tw_dist::tw_o      AS tw_o,
                tw_dist::tw_i      AS tw_i,
                break_dn::ms_tw_o  AS ms_tw_o,
                break_dn::hsh_o    AS hsh_o,
                break_dn::sm_o     AS sm_o,
                break_dn::url_o    AS url_o,
                cut_at::rank       AS at_tr,
                cut_fo::rank       AS fo_tr
           ;

out = FILTER flat BY sn != '0';
rmf $METRICS;
STORE out INTO '$METRICS';
