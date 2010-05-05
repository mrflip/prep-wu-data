-- [screen_name, keyword_bag, number of tweets countaining keywords, time of last tweet containing keyword, profile created at, followers, friends, trstrank]


%default TWEETBAG    '/data/social/network/twitter/client/beggars_group/tweet_bag'
%default RANKEDUSERS '/data/social/network/twitter/fixd/objects/pagerank_with_profile'

Tweets = LOAD '$TWEETBAG' AS (
                tweet_id:              long,
                created_at:            long,
                user_id:               long,
                favorited:             long,
                truncated:             int,
                in_reply_to_user_id:   long,
                in_reply_to_status_id: long,
                text:                  chararray,
                source:                chararray,
                keywords:              chararray
        );

Users = LOAD '$RANKEDUSERS' AS (
                user_id:    long,
                pgrnk:      float,
                followers:  long,
                ratio:      float, --followers/friends
                created_at: long
        );

Joined        = JOIN Tweets BY user_id, Users BY user_id;
Tst = LIMIT Joined 100;
DUMP Tst;
-- Relevant      = FOREACH Joined {
--                         keyword_bag = DISTINCT(TOKENIZE(Tweets::keywords));
--                         GENERATE
--                                 Users::user_id AS user_id,
--                                 keyword_bag AS keywords,
--                                 COUNT(keyword_bag) AS num_words,
--                                 MAX(Tweets::created_at) AS time_of_last,
--                                 Users::created_at AS profile_creation_date,
--                                 Users::followers AS followers,
--                                 Users::ratio AS ratio,
--                                 Users::pgrnk AS pgrnk
--                                 ;
--                         };
-- Dump Relevant;
                
