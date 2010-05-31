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
