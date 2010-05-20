%default AFOLLOWSB '/data/sn/tw/fixd/objects/a_follows_b'
%default AATSIGNSB '/data/sn/tw/fixd/objects/a_atsigns_b'
%default MATCHED   '/data/sn/tw/fixd/objects/twitter_user_id_matched'        
%default USER_ID   '15748351' --infochimps
%default HOOD      '/data/sn/tw/cool/infochimps_hood'

-- load follow graph        
FollowGraph = LOAD '$AFOLLOWSB' AS (
                  rsrc:                 chararray,
                  user_a_id:            long,
                  user_b_id:            long
             );

-- load atsign graph
AtsignGraph = LOAD '$AATSIGNSB' AS (
                  rsrc:                 chararray,
                  user_a_id:            long,
                  user_b_name:          chararray,
                  tweet_id:             long
             );

AtGraphCut = FOREACH AtsignGraph GENERATE user_a_id, user_b_name;

-- load matched ids
MatchedIds = LOAD '$MATCHED' AS (
                  rsrc:             chararray,
                  user_id:          long,
                  scraped_at:       long,
                  screen_name:      chararray,
                  protected:        int,
                  followers_count:  long,
                  friends_count:    long,
                  statuses_count:   long,
                  favourites_count: long,
                  created_at:       long,
                  search_id:        long,
                  is_full:          long,
                  health:           chararray
             );

-- make the atsign graph look alot more like the follow graph
MatchMap      = FOREACH MatchedIds GENERATE user_id, screen_name;
AtGraphJoined = JOIN AtGraphCut BY user_b_name, MatchMap BY screen_name;
AtGraph       = FOREACH AtGraphJoined GENERATE AtGraphCut::user_a_id AS user_a_id, MatchMap::user_id AS user_b_id;

-- get followers and followees of USER
Out1      = FILTER FollowGraph BY user_a_id == (long)'$USER_ID'; -- USER --> Out1
Out1Users = FOREACH Out1 GENERATE user_b_id AS user;
In1       = FILTER FollowGraph BY user_b_id == (long)'$USER_ID'; -- USER <-- In1
In1Users  = FOREACH In1 GENERATE user_a_id AS user;

-- get atsigners and atsignees of USER
AtOut      = FILTER AtGraph BY user_a_id == (long)'$USER_ID'; -- USER --> @AtOut
AtOutUsers = FOREACH AtOut GENERATE user_b_id AS user;
AtIn       = FILTER AtGraph BY user_b_id == (long)'$USER_ID'; -- @USER <-- AtIn
AtInUsers  = FOREACH AtIn GENERATE user_a_id AS user;

Neighborhood = UNION Out1Users, In1Users, AtOutUsers, AtInUsers;

rmf $HOOD;
STORE Neighborhood INTO '$HOOD';
