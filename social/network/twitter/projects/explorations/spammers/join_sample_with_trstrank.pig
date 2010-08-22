%default TRST '/data/sn/tw/fixd/pagerank/a_follows_b_with_fo'
%default SMP  '/data/sn/tw/fixd/sample/twitter_user_id'
%default OUT  '/tmp/sample_with_fo_rank'
        
trstrank = LOAD '$TRST' AS (uid:long, followers:long, scaled:float);        
list     = LOAD '$SMP'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
cut_list = FOREACH list GENERATE uid;
joined   = JOIN trstrank BY uid, cut_list BY uid using 'replicated';
out      = FOREACH joined GENERATE trstrank::scaled AS scaled, trstrank::followers AS followers;

rmf $OUT;
STORE out INTO '$OUT';
