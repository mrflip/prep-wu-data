
%default TWROOT '/data/sn/tw/fixd/objects'

AFollowsB           = LOAD '$TWROOT/a_follows_b'           AS (rsrc: chararray, user_a_id: long, user_b_id: long);
ARetweetsB_N        = LOAD '$TWROOT/a_retweets_b'          AS (rsrc: chararray, user_a_id: long, user_b_name: chararray,    tw_id: long, pls_flag:long, text:chararray);
AAtsignsB_N         = LOAD '$TWROOT/a_atsigns_b'           AS (rsrc: chararray, user_a_id: long, user_b_name: chararray,    tw_id: long);
ARepliesB           = LOAD '$TWROOT/a_replies_b'           AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long, reply_tw_id:long);
AFavoritesB         = LOAD '$TWROOT/a_favorites_b'         AS (rsrc: chararray, user_a_id: long, user_b_id: long,            tw_id: long);

%default USER_ID   '15748351' --infochimps
%default HOOD      '/data/sn/tw/cool/infochimps_hood'


-- get followers and followees of USER
n_FOo      = FILTER AFollowsB BY user_a_id == $USER_ID;         -- USER --> Out1
n_FOi      = FILTER AFollowsB BY user_b_id == $USER_ID;         -- USER <-- In1

-- get atsigners and atsignees of USER
n_REo      = FILTER ARepliesB BY user_a_id == $USER_ID;         -- USER --> Replies out
n_REo      = FILTER ARepliesB BY user_b_id == $USER_ID;         -- USER <-- Replies in

-- rmf               $HOOD/n_FOo ;
-- STORE n_FOo INTO '$HOOD/n_FOo';

rmf               $HOOD/n_REo ;
STORE n_REo INTO '$HOOD/n_REo';
