-- Twitter Users observed in full corpus and in our captured sample
--
-- Month    n_capd  min_user_id       n_tweets        captured_fraction
-- 200810   24194   941248087       43326420       5.584121651408078E-4
-- 200811   29502   984577018       46809535       6.302562074158609E-4
-- 200812   41653  1031391115       57637121       7.226766236294141E-4
-- 200901   61634  1089028849       76627719       8.043303494392153E-4
-- 200902   83843  1165657297       98078775       8.548536622730045E-4
-- 

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTMTH  '/data/rawd/social/network/twitter/census/users_by_mth_created'
%default OUTDAY  '/data/rawd/social/network/twitter/census/users_by_day_created'
%default OUTHOUR '/data/rawd/social/network/twitter/census/users_by_hour_created'
%default USERS  '/data/rawd/social/network/twitter/scrape_stats/twitter_user_ids'
%default TMPTW   '/tmp/users_by_created_at'

-- !!!NOTE!!! we are loading created_at as a CHARARRAY so that we can use substring to take the month.
AllUser_0 = LOAD '$USERS' AS (rsrc_health: chararray, user_id: long, scraped_at: chararray, screen_name: chararray, protected: int, followers_count: long, friends_count: long, statuses_count: long, favorites_count: long, created_at: chararray, is_full:int);
AllUser_1 = FOREACH AllUser_0 GENERATE user_id, created_at;
AllUser   = FILTER  AllUser_1 BY (created_at IS NOT NULL);
-- rmf                 $TMPTW
-- STORE AllUser INTO '$TMPTW';
-- AllUser   = LOAD '$TMPTW' AS (user_id:long, created_at:chararray);

--
-- Month
--
TwitterUserMth   = FOREACH AllUser GENERATE user_id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 6) AS crat_mth ;
CreatedAtMthGroup = GROUP TwitterUserMth BY crat_mth;
CreatedAtMthCount = FOREACH CreatedAtMthGroup GENERATE
  group                                                 AS crat_mth,
  COUNT(TwitterUserMth)                                 AS n_captured,
  MIN(TwitterUserMth.user_id)                             AS min_user_id,
  MAX(TwitterUserMth.user_id) - MIN(TwitterUserMth.user_id) AS n_users,
  ( ((double) COUNT(TwitterUserMth)) / ((double) (MAX(TwitterUserMth.user_id) - MIN(TwitterUserMth.user_id))) ) AS captured_fraction
  ;
rmf $OUTMTH;
STORE CreatedAtMthCount INTO '$OUTMTH';

--
-- Day
--
TwitterUserDay   = FOREACH AllUser GENERATE user_id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 8) AS crat_day ;
CreatedAtDayGroup = GROUP TwitterUserDay BY crat_day;
CreatedAtDayCount = FOREACH CreatedAtDayGroup GENERATE
  group                                                   AS crat_day,
  COUNT(TwitterUserDay)                                  AS n_captured,
  MIN(TwitterUserDay.user_id)                              AS min_user_id,
  MAX(TwitterUserDay.user_id) - MIN(TwitterUserDay.user_id) AS n_users,
  ( ((double) COUNT(TwitterUserDay)) / ((double) (MAX(TwitterUserDay.user_id) - MIN(TwitterUserDay.user_id))) ) AS captured_fraction
  ;
rmf $OUTDAY;
STORE CreatedAtDayCount INTO '$OUTDAY';

--
-- Hour
--
TwitterUserHour   = FOREACH AllUser GENERATE user_id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 10) AS crat_hour ;
CreatedAtHourGroup = GROUP TwitterUserHour BY crat_hour;
CreatedAtHourCount = FOREACH CreatedAtHourGroup GENERATE
  group                                                   AS crat_hour,
  COUNT(TwitterUserHour)                                  AS n_captured,
  MIN(TwitterUserHour.user_id)                              AS min_user_id,
  MAX(TwitterUserHour.user_id) - MIN(TwitterUserHour.user_id) AS n_users,
  ( ((double) COUNT(TwitterUserHour)) / ((double) (MAX(TwitterUserHour.user_id) - MIN(TwitterUserHour.user_id))) ) AS captured_fraction
  ;
rmf $OUTHOUR;
STORE CreatedAtHourCount INTO '$OUTHOUR';

-- rmf $TMPTW

