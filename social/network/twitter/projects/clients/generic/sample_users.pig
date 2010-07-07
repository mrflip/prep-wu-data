%default USER  '/data/sn/tw/fixd/objects/twitter_user'
%default SMPLD '/data/sn/tw/client/generic/sampled_users'
        
user    = LOAD '$USER' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long);
sampled = SAMPLE user 0.0001; --get 0.01 percent of users ~4k

rmf $SMPLD;
STORE sampled INTO '$SMPLD';
