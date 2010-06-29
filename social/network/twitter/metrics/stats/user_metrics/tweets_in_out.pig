--
-- Get raw estimate of tweets in for every user. Needs to be divided by a users account age
--
%default FOLLOW  '/data/sn/tw/fixd/objects/a_follows_b'
%default USER    '/data/sn/tw/fixd/objects/twitter_user'
%default TWOUTIN '/data/sn/tw/fixd/graph/tweets_out_in'
        
users   = LOAD '$USER'   AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:long, friends:long, statuses:long, favs:long, crat:long);
follows = LOAD '$FOLLOW' AS (rsrc:chararray, user_a_id:long, user_b_id:long);

-- generate distribution of tweets coming in
cut_users = FOREACH users GENERATE uid, statuses, crat;
joined    = JOIN cut_users BY uid, follows BY user_b_id;
tw_in     = FOREACH joined GENERATE
                follows::user_a_id  AS user_id,
                cut_users::statuses AS tweets_in
            ;

grouped    = GROUP tw_in BY user_id;
tw_in_dist = FOREACH grouped GENERATE group AS user_id, SUM(tw_in.tweets_in) AS tot_tweets_in;

-- generate distribution of tweets going out and in
joined_again = JOIN tw_in_dist BY user_id, cut_users BY uid;
tw_outin     = FOREACH joined_again GENERATE
                        tw_in_dist::user_id   AS user_id,
                        tw_in_dist::tweets_in AS tweets_in,
                        cut_users::statuses   AS tweets_out,
                        cut_users::crat       AS crat
               ;

rmf $USERS;
STORE tw_outin INTO '$TWOUTIN';
