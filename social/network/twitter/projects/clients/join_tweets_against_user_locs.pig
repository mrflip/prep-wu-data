%default TWBAG    '/data/sn/tw/client/beggars_group/recent_tweet_bag'
%default ALMOST   '/data/sn/tw/client/beggars_group/users_with_free_location_field'
        
-- pull out uid, sn, location from user locations and emit that as one thing

tweet_bag = LOAD '$TWBAG'  AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, ir_to_uid:long, ir_to_sn:chararray, ir_to_sid:long, ir_to_stid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was:long);
loc_obj   = LOAD '$ALMOST' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, loc:chararray );

cut_tweet_bag = FOREACH tweet_bag GENERATE uid;
cut_loc       = FOREACH loc_obj GENERATE uid, sn, loc;
select_users  = JOIN cut_tweet_bag BY uid, cut_loc BY uid USING 'replicated';

rmf $ALMOST;
STORE select_users INTO '$ALMOST;'
