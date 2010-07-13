-- Generate the twitter relationship mutligraph from all relationships, preserving the rsrc

%default FOLLOW   '/data/sn/tw/fixd/objects/a_follows_b'
%default FAVORITE '/data/sn/tw/fixd/objects/a_favorites_b'
%default REPLY    '/data/sn/tw/fixd/objects/a_replies_b'
%default ATSIGN   '/data/sn/tw/fixd/objects/a_atsigns_b'
%default RETWEET  '/data/sn/tw/fixd/objects/a_retweets_b'
%default MULTI    '/data/sn/tw/fixd/objects/multigraph'
        
follows   = LOAD '$FOLLOW'   AS (rsrc:chararray, user_a_id:long, user_b_id:long);
favorites = LOAD '$FAVORITE' AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long);
replies   = LOAD '$REPLY'    AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long, in_reply_to_tweet_id:long, crat:long);
atsigns   = LOAD '$ATSIGN'   AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long);
retweets  = LOAD '$RETWEET'  AS (rsrc:chararray, user_a_id:long, user_b_id:long, tweet_id:long, please_flag:int);

cut_fav   = FOREACH favorites GENERATE rsrc, user_a_id, user_b_id;
cut_rep   = FOREACH replies   GENERATE rsrc, user_a_id, user_b_id;
cut_ats   = FOREACH atsigns   GENERATE rsrc, user_a_id, user_b_id;
cut_ret   = FOREACH retweets  GENERATE rsrc, user_a_id, user_b_id;

multigraph = UNION follows, cut_fav, cut_rep, cut_ats, cut_ret;

rmf $MULTI;
STORE multigraph INTO '$MULTI';


