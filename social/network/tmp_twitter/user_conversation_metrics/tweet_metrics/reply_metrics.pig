-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default REPLY_OUT '/data/sn/tw/fixd/infl_metrics/reply_out_counts'
%default REPLY_IN '/data/sn/tw/fixd/infl_metrics/reply_in_counts'
-- %default REPLY_OUT '/home/doncarlo/twitter/reply_out_counts'
-- %default REPLY_IN '/home/doncarlo/twitter/reply_in_counts'
%default TW_USER '/data/sn/tw/fixd/objects/twitter_user'
-- %default TW_USER '/data/rawd/social/network/twitter/objects/twitter_user'
%default OUTPUT '/data/sn/tw/fixd/infl_metrics/reply_metrics'
-- %default OUTPUT '/home/doncarlo/twitter/reply_metrics'

-- load reply data
RepsOut = LOAD '$REPLY_OUT' AS (user_id:long,
                                rep_out:long);
RepsIn = LOAD '$REPLY_IN' AS (user_id:long,
                              rep_in:long);

-- join replies out and replies in by user id
ReplyJoin = JOIN RepsOut BY user_id FULL OUTER, 
                 RepsIn BY user_id;
ReplyFlux = FOREACH ReplyJoin GENERATE 
  (RepsOut::user_id IS NULL ? RepsIn::user_id : RepsOut::user_id) AS id,
  (RepsOut::rep_out IS NULL ? 0 : RepsOut::rep_out) AS rep_out,
  (RepsIn::rep_in IS NULL ? 0 : RepsIn::rep_in) AS rep_in;

-- load user data
User = LOAD '$TW_USER' AS (rsrc:chararray, id:long, scraped:long,
                         screen_name:chararray, protected:int,
                         followers:long, friends:long,
                         statuses:long, favorites:long,
                         created:long);

-- only want id, scraped, screen_name, statuses, created from users
UserInfo = FOREACH User GENERATE id, screen_name, statuses, scraped, created;

-- join users with reply data on user id
ReplyUserJoin = JOIN UserInfo BY id FULL OUTER, 
                     ReplyFlux BY id;
ReplyMetrics = FOREACH ReplyUserJoin GENERATE
  UserInfo::screen_name AS screen_name,
  (UserInfo::id IS NULL ? ReplyFlux::id : UserInfo::id) AS id,
  UserInfo::statuses AS statuses,
  (ReplyFlux::rep_out IS NULL ? 0 : ReplyFlux::rep_out) AS rep_out,
  (ReplyFlux::rep_in IS NULL ? 0 : ReplyFlux::rep_in) AS rep_in,
  UserInfo::scraped AS scraped,
  UserInfo::created AS created;

rmf $OUTPUT;
STORE ReplyMetrics INTO '$OUTPUT';
