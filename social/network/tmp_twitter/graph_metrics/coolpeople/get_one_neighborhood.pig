
--
-- Get the 1-neighborhood for a single node:
--    all follow in/out and reply in/out
-- 


%default TWROOT    '/data/sn/tw/fixd/objects'
%default USER_ID   '15748351L' --infochimps
%default HOOD      '/data/sn/tw/cool/infochimps_hood'

AFollowsB           = LOAD '$TWROOT/a_follows_b'           AS (rsrc: chararray, user_a_id: long, user_b_id: long);
ARetweetsB_N        = LOAD '$TWROOT/a_retweets_b'          AS (rsrc: chararray, user_a_id: long, user_b_name: chararray,    tw_id: long, pls_flag:long, text:chararray);
AAtsignsB_N         = LOAD '$TWROOT/a_atsigns_b'           AS (rsrc: chararray, user_a_id: long, user_b_name: chararray,    tw_id: long);
ARepliesB           = LOAD '$TWROOT/a_replies_b'           AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long, reply_tw_id:long);
AFavoritesB         = LOAD '$TWROOT/a_favorites_b'         AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long);


-- get followers and followees of USER
e_FOo      = FILTER AFollowsB BY user_a_id == $USER_ID;         -- USER --> Out1
e_FOi      = FILTER AFollowsB BY user_b_id == $USER_ID;         -- USER <-- In1

-- get atsigners and atsignees of USER
e_REo      = FILTER ARepliesB BY user_a_id == $USER_ID;         -- USER --> Replies out
e_REi      = FILTER ARepliesB BY user_b_id == $USER_ID;         -- USER <-- Replies in


-- rmf               $HOOD/e_FOo ;
-- STORE e_FOo INTO '$HOOD/e_FOo';
-- rmf               $HOOD/e_FOi ;
-- STORE e_FOi INTO '$HOOD/e_FOi';
--
-- rmf               $HOOD/e_REo ;
-- STORE e_REo INTO '$HOOD/e_REo';
-- rmf               $HOOD/e_REi ;
-- STORE e_REi INTO '$HOOD/e_REi';

