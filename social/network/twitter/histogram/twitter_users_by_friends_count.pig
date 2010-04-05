/*
From

tweets

      [:id,                      Integer     ],
      [:created_at,              Bignum      ],
      [:twitter_user_id,         Integer     ],
      [:favorited,               Integer     ],
      [:truncated,               Integer     ],
      [:in_reply_to_user_id,     Integer     ],
      [:in_reply_to_status_id,   Integer     ],
      [:text,                    String      ],
      [:source,                  String      ],
      [:in_reply_to_screen_name, String      ]


twitter_users

      [:id,                     Integer],
      [:scraped_at,             Bignum],
      [:screen_name,            String],
      [:protected,              Integer],
      [:followers_count,        Integer],
      [:friends_count,          Integer],
      [:statuses_count,         Integer],
      [:favourites_count,       Integer],
      [:created_at,             Bignum]


twitter_user_profiles

      [:id,                     Integer],
      [:scraped_at,             Bignum],
      [:name,                   String],
      [:url,                    String],
      [:location,               String],
      [:description,            String],
      [:time_zone,              String],
      [:utc_offset,             String]

twitter_user_partials

      [:id,                     Integer],       # appear in TwitterUser
      [:scraped_at,             Bignum],
      [:screen_name,            String],
      [:protected,              Integer],
      [:followers_count,        Integer],
      [:name,                   String],        # appear in TwitterUserProfile
      [:url,                    String],
      [:location,               String],
      [:description,            String],
      [:profile_image_url,      String]         # appear in TwitterUserStyle
	
*/


-- This script results in a tsv of users by friends count across the whole twitter stream.
-- ie:
--
--     friends  num_users
--
--     1        1000
--     23       40
--     1498     1
--
--


-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- defaults
%default OUTPUT '/home/jacob/users_by_followers_count'
%default USER   '/data/fixd/social/network/twitter/models/twitter_user';

AllUser       = LOAD '$USER' AS (rsrc:chararray, id:long, scraped_at:long, screen_name:chararray, protected:long, followers_count:long, friends_count:long, statuses_count:long, favourites_count:long, created_at:long);
TwitterUser   = FOREACH AllUser GENERATE id, friends_count;
UserWFriend   = FILTER TwitterUser BY friends_count IS NOT NULL;

FriendGroup   = GROUP UserWFriend BY friends_count;
FriendCount   = FOREACH FriendGroup GENERATE group, COUNT(UserWFriend);

rmf $OUTPUT;
STORE FriendCount INTO '$OUTPUT';
