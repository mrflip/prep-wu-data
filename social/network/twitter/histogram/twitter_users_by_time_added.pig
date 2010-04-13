/*
From

tweets

      [:id, Integer ],
      [:created_at, Bignum ],
      [:twitter_user_id, Integer ],
      [:favorited, Integer ],
      [:truncated, Integer ],
      [:in_reply_to_user_id, Integer ],
      [:in_reply_to_status_id, Integer ],
      [:text, String ],
      [:source, String ],
      [:in_reply_to_screen_name, String ]


twitter_users

      [:id, Integer],
      [:scraped_at, Bignum],
      [:screen_name, String],
      [:protected, Integer],
      [:followers_count, Integer],
      [:friends_count, Integer],
      [:statuses_count, Integer],
      [:favourites_count, Integer],
      [:created_at, Bignum]


twitter_user_profiles

      [:id, Integer],
      [:scraped_at, Bignum],
      [:name, String],
      [:url, String],
      [:location, String],
      [:description, String],
      [:time_zone, String],
      [:utc_offset, String]

twitter_user_partials

      [:id, Integer], # appear in TwitterUser
      [:scraped_at, Bignum],
      [:screen_name, String],
      [:protected, Integer],
      [:followers_count, Integer],
      [:name, String], # appear in TwitterUserProfile
      [:url, String],
      [:location, String],
      [:description, String],
      [:profile_image_url, String] # appear in TwitterUserStyle

*/


-- This script results in a tsv of users by their creation date across the whole twitter stream.
-- ie:
--
-- friends created_at
--
-- 1 1000
-- 23 40
-- 1498 1
--
--


-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTMTH '/data/pkgd/social/network/twitter/users_by_month_created'
%default OUTDAY '/data/pkgd/social/network/twitter/users_by_day_created'
%default OUTHR '/data/pkgd/social/network/twitter/users_by_hour_created'
%default USER '/data/rawd/social/network/twitter/objects/twitter_user';

AllUser = LOAD '$USER' AS (rsrc:chararray, id:long, scraped_at:long, 
                           screen_name:chararray, protected:long, 
                           followers_count:long, friends_count:long, 
                           statuses_count:long, favourites_count:long, created_at:chararray);

TwitterUserMth = FOREACH AllUser GENERATE id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 6) AS created_at;
UserMthCreatedAt = FILTER TwitterUserMth BY created_at IS NOT NULL;

CreatedAtMthGroup = GROUP UserMthCreatedAt BY created_at;
CreatedAtMthCount = FOREACH CreatedAtMthGroup GENERATE group, COUNT(UserMthCreatedAt);

rmf $OUTMTH;
STORE CreatedAtMthCount INTO '$OUTMTH';


TwitterUserDay = FOREACH AllUser GENERATE id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 8) AS created_at;
UserDayCreatedAt = FILTER TwitterUserDay BY created_at IS NOT NULL;

CreatedAtDayGroup = GROUP UserDayCreatedAt BY created_at;
CreatedAtDayCount = FOREACH CreatedAtDayGroup GENERATE group, COUNT(UserDayCreatedAt);

rmf $OUTDAY;
STORE CreatedAtDayCount INTO '$OUTDAY';


TwitterUserHr = FOREACH AllUser GENERATE id, org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 10) AS created_at;
UserHrCreatedAt = FILTER TwitterUserHr BY created_at IS NOT NULL;

CreatedAtHrGroup = GROUP UserHrCreatedAt BY created_at;
CreatedAtHrCount = FOREACH CreatedAtHrGroup GENERATE group, COUNT(UserHrCreatedAt);

rmf $OUTHR;
STORE CreatedAtHrCount INTO '$OUTHR';
