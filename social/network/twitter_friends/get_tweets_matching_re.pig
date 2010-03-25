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

-- defaults, the path to tweets is different on the clusta
%default TWEET   '/data/fixd/social/network/twitter/out/tweet' ;
%default OUTPUT  '/data/fixd/social/network/twitter/ford_counts';
-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- tweets
full_tweet = LOAD '$TWEET' AS (rsrc:chararray, id:long, created_at:long, user_id:long, favorited:int, truncated:int, reply_to_user_id:long, reply_to_status_id:long, text:chararray, source:chararray, reply_to_screen_name:chararray) ;                      -- (tweet,56,20060321224142,21,0,0,,,twttr my nttr,web,)
tweet = FOREACH full_tweet GENERATE user_id, created_at, text; -- (21,already addicted to twttr.com)

-- filter tweets by regexp
matched_tweet = FILTER tweet
  BY      org.apache.pig.piggybank.evaluation.string.UPPER(text)
  MATCHES '$REGEXP' ;
grouped_matched_tweet = GROUP matched_tweet BY user_id;
tweet_count   = FOREACH grouped_matched_tweet GENERATE group AS user_id, COUNT(matched_tweet);
-- tweet_count_sample = LIMIT tweet_count 100; DUMP tweet_count_sample;
STORE tweet_count INTO '$OUTPUT';
