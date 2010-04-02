-- load init_load.pig

%default REDUCE_TASKS 40

-- %default TWITTER_USER_FILE  fixd/tw/out/twitter_user
%default TWITTER_USER_IDS     fixd/tw/out/twitter_user_id
%default TWITTER_IDS_MAP_FILE tmp/twitter_user_name_to_id
%default ATSIGNS_SRC_DIR      fixd/tw/networks
%default ATSIGNS_OUT_DIR      fixd/tw/networks

-- ===========================================================================
--
-- UserID Map
--

-- TwitterUserId_0 = LOAD '$TWITTER_USER_IDS' AS (
--   rsrc: chararray, user_id: long, screen_name: chararray, protected: long,
--   followers_count: long, created_at: long);
-- TwitterUserId_1 = FILTER  TwitterUserId_0 BY (rsrc MATCHES '^twitter_user_id(|-protected|-partial)$');
-- TwitterUserId   = FOREACH TwitterUserId_1 GENERATE user_id, screen_name ;
-- rmf                      $TWITTER_IDS_MAP_FILE  ;
-- STORE TwitterUserId INTO '$TWITTER_IDS_MAP_FILE' ;
TwitterUserId = LOAD '$TWITTER_IDS_MAP_FILE' AS (user_id:long, screen_name:chararray) ;


-- ===========================================================================
--
-- Twitter API objects [id, name]
--

-- /part-00000
ARetweetsB_IN   = LOAD    '$ATSIGNS_SRC_DIR/a_retweets_b' AS (rsrc:chararray, user_a_id:long, user_b_name: chararray, tw_id:long, rt_whore:long );
ARetweetsB_1    = JOIN    TwitterUserId BY screen_name, ARetweetsB_IN BY user_b_name PARALLEL $REDUCE_TASKS;
ARetweetsB_2    = FOREACH ARetweetsB_1  GENERATE 'a_retweets_b_id' AS rsrc, user_a_id AS user_a_id, TwitterUserId::user_id AS user_b_id, tw_id, rt_whore ;
-- ILLUSTRATE TwitterUserId ; 
-- ILLUSTRATE ARetweetsB_IN ; 
rmf                       $ATSIGNS_OUT_DIR/a_retweets_b_id_t
STORE ARetweetsB_2 INTO  '$ATSIGNS_OUT_DIR/a_retweets_b_id_t' ;


-- /part-00001
AAtsignsB_IN    = LOAD    '$ATSIGNS_SRC_DIR/a_atsigns_b' AS (rsrc:chararray, user_a_id:long, user_b_name: chararray, tw_id:long );
AAtsignsB_1     = JOIN    TwitterUserId BY screen_name, AAtsignsB_IN BY user_b_name PARALLEL $REDUCE_TASKS;
AAtsignsB_2     = FOREACH AAtsignsB_1  GENERATE 'a_atsigns_b_id' AS rsrc, user_a_id AS user_a_id, TwitterUserId::user_id AS user_b_id, tw_id ;
-- ILLUSTRATE AAtsignsB_IN ;
rmf                        $ATSIGNS_OUT_DIR/a_atsigns_b_id_t
STORE AAtsignsB_2 INTO    '$ATSIGNS_OUT_DIR/a_atsigns_b_id_t' ;

-- -- ===========================================================================
-- --
-- -- Twitter API objects [name, name]
-- --

--/part-00008
ARepliesB_NN    = LOAD '$ATSIGNS_SRC_DIR/a_replies_b_name' AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, in_re_tw_id:long );
ARepliesB_NN1   = JOIN    TwitterUserId BY screen_name, ARepliesB_NN  BY user_a_name PARALLEL $REDUCE_TASKS;
ARepliesB_NN2   = FOREACH ARepliesB_NN1  GENERATE TwitterUserId::user_id AS user_a_id,  user_b_name, tw_id ;
ARepliesB_NN3   = JOIN    TwitterUserId BY screen_name, ARepliesB_NN2 BY user_b_name PARALLEL $REDUCE_TASKS;
ARepliesB_NN4   = FOREACH ARepliesB_NN3  GENERATE
   'a_replies_b' AS rsrc, user_a_id, TwitterUserId::user_id AS user_b_id, tw_id ;
-- ILLUSTRATE ARepliesB_NN ; 
rmf                       $ATSIGNS_OUT_DIR/a_replies_b_s
STORE ARepliesB_NN4 INTO '$ATSIGNS_OUT_DIR/a_replies_b_s' ;

-- /part-00001
AAtsignsB_NN    = LOAD '$ATSIGNS_SRC_DIR/a_atsigns_b_name' AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, sid:long );
AAtsignsB_NN1   = JOIN    TwitterUserId BY screen_name, AAtsignsB_NN  BY user_a_name PARALLEL $REDUCE_TASKS;
AAtsignsB_NN2   = FOREACH AAtsignsB_NN1  GENERATE TwitterUserId::user_id AS user_a_id,  user_b_name, tw_id ;
AAtsignsB_NN3   = JOIN    TwitterUserId BY screen_name, AAtsignsB_NN2 BY user_b_name PARALLEL $REDUCE_TASKS;
AAtsignsB_NN4   = FOREACH AAtsignsB_NN3  GENERATE
   'a_atsigns_b_id' AS rsrc, user_a_id, TwitterUserId::user_id AS user_b_id, tw_id ;
-- ILLUSTRATE AAtsignsB_NN ; 
rmf                       $ATSIGNS_OUT_DIR/a_atsigns_b_id_s
STORE AAtsignsB_NN4 INTO '$ATSIGNS_OUT_DIR/a_atsigns_b_id_s' ;

-- /part-00000
ARetweetsB_NN    = LOAD '$ATSIGNS_SRC_DIR/a_retweets_b_name' AS (rsrc:chararray, user_a_name:chararray, user_b_name: chararray, tw_id:long, rt_whore:long, sid:long );
ARetweetsB_NN1   = JOIN    TwitterUserId BY screen_name, ARetweetsB_NN  BY user_a_name PARALLEL $REDUCE_TASKS;
ARetweetsB_NN2   = FOREACH ARetweetsB_NN1  GENERATE TwitterUserId::user_id AS user_a_id,  user_b_name, tw_id, rt_whore ;
ARetweetsB_NN3   = JOIN    TwitterUserId BY screen_name, ARetweetsB_NN2 BY user_b_name PARALLEL $REDUCE_TASKS;
ARetweetsB_NN4   = FOREACH ARetweetsB_NN3  GENERATE
   'a_retweets_b_id' AS rsrc, user_a_id, TwitterUserId::user_id AS user_b_id, tw_id ;
-- ILLUSTRATE ARetweetsB_NN ; 
rmf                        $ATSIGNS_OUT_DIR/a_retweets_b_id_s
STORE ARetweetsB_NN4 INTO '$ATSIGNS_OUT_DIR/a_retweets_b_id_s' ;
