-- Tweet rate in full corpus and in our captured sample
--
-- Month    n_capd  min_tw_id       n_tweets        captured_fraction
-- 200810   24194   941248087       43326420       5.584121651408078E-4
-- 200811   29502   984577018       46809535       6.302562074158609E-4
-- 200812   41653  1031391115       57637121       7.226766236294141E-4
-- 200901   61634  1089028849       76627719       8.043303494392153E-4
-- 200902   83843  1165657297       98078775       8.548536622730045E-4
-- 

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTMTH  '/data/rawd/social/network/twitter/census/tweets_by_mth_created'
%default OUTDAY  '/data/rawd/social/network/twitter/census/tweets_by_day_created'
%default OUTHOUR '/data/rawd/social/network/twitter/census/tweets_by_hour_created'
%default TMPTW   '/data/rawd/social/network/twitter/scrape_stats/tweet_id_vs_created_at'
%default TWEETS  '/data/rawd/social/network/twitter/objects/*tweet'

-- !!!NOTE!!! we are loading created_at as a CHARARRAY so that we can use substring to take the month.
AllTweet_0 = LOAD '$TWEETS';
AllTweet_1 = FOREACH AllTweet_0 GENERATE (long) $1 AS tw_id, (chararray) $2 AS created_at;
AllTweet   = FILTER  AllTweet_1 BY (created_at IS NOT NULL) AND (tw_id < 20000000000L);
-- rmf                  $TMPTW
-- STORE AllTweet INTO '$TMPTW';
-- AllTweet   = LOAD '$TMPTW' AS (tw_id:long, created_at:chararray);

-- --
-- -- Month
-- --
-- TwitterTweetMth   = FOREACH AllTweet GENERATE tw_id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 6) AS crat_mth ;
-- CreatedAtMthGroup = GROUP TwitterTweetMth BY crat_mth;
-- CreatedAtMthCount = FOREACH CreatedAtMthGroup GENERATE
--   group                                                   AS crat_mth,
--   COUNT(TwitterTweetMth)                                  AS n_captured,
--   MIN(TwitterTweetMth.tw_id)                              AS min_tweet_id,
--   MAX(TwitterTweetMth.tw_id) - MIN(TwitterTweetMth.tw_id) AS n_tweets,
--   ( ((double) COUNT(TwitterTweetMth)) / ((double) (MAX(TwitterTweetMth.tw_id) - MIN(TwitterTweetMth.tw_id))) ) AS captured_fraction
--   ;
-- rmf $OUTMTH;
-- STORE CreatedAtMthCount INTO '$OUTMTH';

-- --
-- -- Day
-- --
-- TwitterTweetDay   = FOREACH AllTweet GENERATE tw_id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 8) AS crat_day ;
-- CreatedAtDayGroup = GROUP TwitterTweetDay BY crat_day;
-- CreatedAtDayCount = FOREACH CreatedAtDayGroup GENERATE
--   group                                                   AS crat_day,
--   COUNT(TwitterTweetDay)                                  AS n_captured,
--   MIN(TwitterTweetDay.tw_id)                              AS min_tweet_id,
--   MAX(TwitterTweetDay.tw_id) - MIN(TwitterTweetDay.tw_id) AS n_tweets,
--   ( ((double) COUNT(TwitterTweetDay)) / ((double) (MAX(TwitterTweetDay.tw_id) - MIN(TwitterTweetDay.tw_id))) ) AS captured_fraction
--   ;
-- rmf $OUTDAY;
-- STORE CreatedAtDayCount INTO '$OUTDAY';

--
-- Hour
--
TwitterTweetHour   = FOREACH AllTweet GENERATE tw_id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 10) AS crat_hour ;
CreatedAtHourGroup = GROUP TwitterTweetHour BY crat_hour;
CreatedAtHourCount = FOREACH CreatedAtHourGroup GENERATE
  group                                                   AS crat_hour,
  COUNT(TwitterTweetHour)                                  AS n_captured,
  MIN(TwitterTweetHour.tw_id)                              AS min_tweet_id,
  MAX(TwitterTweetHour.tw_id) - MIN(TwitterTweetHour.tw_id) AS n_tweets,
  ( ((double) COUNT(TwitterTweetHour)) / ((double) (MAX(TwitterTweetHour.tw_id) - MIN(TwitterTweetHour.tw_id))) ) AS captured_fraction
  ;
rmf $OUTHOUR;
STORE CreatedAtHourCount INTO '$OUTHOUR';

-- rmf $TMPTW

