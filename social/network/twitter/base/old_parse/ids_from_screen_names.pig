%default TWROOT  '/data/sn/tw/fixd/objects'
%default RELDIR  '/data/sn/tw/fixd/objects'

--
-- Input data
--

ARepliesB           = LOAD '$TWROOT/a_replies_b'             AS (rsrc:chararray, user_a_id:long,        user_b_id:   long,      tw_id:long, in_re_tw_id:long);
ARepliesB_NN        = LOAD '$TWROOT/a_replies_b_name'        AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, in_re_tw_id:long );
AAtsignsB_IN        = LOAD '$TWROOT/a_atsigns_b'             AS (rsrc:chararray, user_a_id:long,        user_b_name: chararray, tw_id:long );
-- AAtsignsB_NN     = LOAD '$TWROOT/a_atsigns_b_name'        AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, sid:long );
ARetweetsB_IN       = LOAD '$TWROOT/a_retweets_b'            AS (rsrc:chararray, user_a_id:long,        user_b_name: chararray, tw_id:long, rt_whore:long );
-- ARetweetsB_NN    = LOAD '$TWROOT/a_retweets_b_name'       AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, rt_whore:long, sid:long );

-- ===========================================================================
--
-- UserID Map
--

-- TwitterUserId       = LOAD '$TWROOT/twitter_user_id_matched' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:long, friends_count:long, statuses_count:long, favourites_count:long, created_at:long, sid:long, is_full:long, health:chararray);
-- UserIdToSn     = FOREACH TwitterUserId GENERATE user_id, screen_name ;
-- rmf                    $TWROOT/id_to_screen_name
-- STORE UserIdToSn INTO '$TWROOT/id_to_screen_name' ;
UserIdToSn  = LOAD '$TWROOT/id_to_screen_name' AS (user_id:long, screen_name:chararray) ;


-- ===========================================================================
--
-- AAtsignsB_IN [id, name]
--

AAtsignsB_1     = JOIN    UserIdToSn BY screen_name, AAtsignsB_IN BY user_b_name;
AAtsignsB_2     = FOREACH AAtsignsB_1  GENERATE 'a_atsigns_b_id' AS rsrc, user_a_id AS user_a_id, UserIdToSn::user_id AS user_b_id, tw_id ;
rmf                     $RELDIR/a_atsigns_b_id
STORE AAtsignsB_2 INTO '$RELDIR/a_atsigns_b_id' ;


-- ===========================================================================
--
-- ARetweetsB_IN [id, name]
--

ARetweetsB_1    = JOIN    UserIdToSn BY screen_name, ARetweetsB_IN BY user_b_name ;
ARetweetsB_2    = FOREACH ARetweetsB_1  GENERATE 'a_retweets_b_id' AS rsrc, user_a_id AS user_a_id, UserIdToSn::user_id AS user_b_id, tw_id, rt_whore ;
rmf                       $RELDIR/a_retweets_b_id
STORE ARetweetsB_2 INTO  '$RELDIR/a_retweets_b_id' ;



-- ===========================================================================
--
-- ARepliesB_NN [name, name]
--

ARepliesB_NN1   = JOIN    UserIdToSn BY screen_name, ARepliesB_NN  BY user_a_name ;
ARepliesB_NN2   = FOREACH ARepliesB_NN1  GENERATE UserIdToSn::user_id AS user_a_id,  user_b_name, tw_id, in_re_tw_id ;
ARepliesB_NN3   = JOIN    UserIdToSn BY screen_name, ARepliesB_NN2 BY user_b_name ;
ARepliesB_NN4   = FOREACH ARepliesB_NN3  GENERATE 'a_replies_b' AS rsrc, user_a_id, UserIdToSn::user_id AS user_b_id, tw_id, in_re_tw_id ;
rmf                       $RELDIR/a_replies_b_s
STORE ARepliesB_NN4 INTO '$RELDIR/a_replies_b_s' ;

-- AAtsignsB_NN1   = JOIN    UserIdToSn BY screen_name, AAtsignsB_NN  BY user_a_name ;
-- AAtsignsB_NN2   = FOREACH AAtsignsB_NN1  GENERATE UserIdToSn::user_id AS user_a_id,  user_b_name, tw_id ;
-- AAtsignsB_NN3   = JOIN    UserIdToSn BY screen_name, AAtsignsB_NN2 BY user_b_name ;
-- AAtsignsB_NN4   = FOREACH AAtsignsB_NN3  GENERATE 'a_atsigns_b_id' AS rsrc, user_a_id, UserIdToSn::user_id AS user_b_id, tw_id ;
-- rmf                       $RELDIR/a_atsigns_b_id_s
-- STORE AAtsignsB_NN4 INTO '$RELDIR/a_atsigns_b_id_s' ;
-- 
-- ARetweetsB_NN1   = JOIN    UserIdToSn BY screen_name, ARetweetsB_NN  BY user_a_name ;
-- ARetweetsB_NN2   = FOREACH ARetweetsB_NN1  GENERATE UserIdToSn::user_id AS user_a_id,  user_b_name, tw_id, rt_whore ;
-- ARetweetsB_NN3   = JOIN    UserIdToSn BY screen_name, ARetweetsB_NN2 BY user_b_name ;
-- ARetweetsB_NN4   = FOREACH ARetweetsB_NN3  GENERATE 'a_retweets_b_id' AS rsrc, user_a_id, UserIdToSn::user_id AS user_b_id, tw_id ;
-- rmf                        $RELDIR/a_retweets_b_id_s
-- STORE ARetweetsB_NN4 INTO '$RELDIR/a_retweets_b_id_s' ;
