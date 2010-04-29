REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

%default SEARCHTWEET '/data/social/network/twitter/fixd/objects/tweet';        --input location
%default TWEET       '/data/social/network/twitter/fixd/objects/search_tweet'; --input location
%default FIXEDIDS    '/data/social/network/twitter/fixd/objects/ids_joined';   --input location ?
%default COOLPPL     '/data/social/network/twitter/sample/cool_ppl';

-- load input data
-- join cool people screen names via search ids to search tweets
-- generate [screen_name, tweet_text]
-- join cool people screen names via api ids to tweets
-- generate [screen_name, tweet_text]
-- union of these two things
-- done for now
