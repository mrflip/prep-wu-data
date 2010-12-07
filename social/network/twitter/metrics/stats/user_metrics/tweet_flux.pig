--
-- Get raw estimate of tweets in and out for every user
--

user_id  = LOAD '$TW_UID' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);        
follows  = LOAD '$A_F_B'  AS (rsrc:chararray, user_a_id:long, user_b_id:long);

senders         = FOREACH user_id GENERATE uid, statuses;
senders_friends = COGROUP cut_users BY uid, follows BY user_b_id; -- need to get a list of people to send statuses to
DESCRIBE senders_friends;
-- receivers       = FOREACH senders_friends GENERATE
--                     FLATTEN(follows.user_a_id) AS uid,            -- user receiving tweets
--                 FLATTEN(cut_users.statuses) AS tweets_in
--             ;
-- 
-- cogrpd    = COGROUP tw_in BY uid, cut_users BY uid;
-- tw_flux   = FOREACH cogrpd GENERATE group AS uid, FLATTEN(cut_users.statuses) AS tw_out, SUM(tw_in.tweets_in) AS tw_in;
-- 
-- rmf $TWFLUX;
-- STORE tw_flux INTO '$TWFLUX';
