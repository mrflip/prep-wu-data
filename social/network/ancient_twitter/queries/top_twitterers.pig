/*

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

*/

-- params	
%default USER		'/data/fixd/tw/models/twitter_user'         ;
%default PROFILE	'/data/fixd/tw/models/twitter_user_profile' ;
%default MOST_FOLLOWERS '/data/anal/most_followers' 		    ;
%default MOST_FRIENDS	'/data/anal/most_friends'  		    ;
%default NUM_USERS      1000					    ;

-- users
full_user = LOAD '$USER' AS (rsrc:chararray, id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:int, friends_count:int, statuses_count:int, favorites_count:int, created_at:long);
user = FOREACH full_user GENERATE id, screen_name, protected, followers_count, friends_count, statuses_count, favorites_count, created_at; -- (2023,cutty,0,37,42,40,1,20060717181309)

user_by_followers_count = ORDER user BY followers_count DESC;
user_by_friends_count   = ORDER user BY friends_count   DESC;

user_with_most_followers = LIMIT user_by_followers_count $NUM_USERS;
DUMP user_with_most_followers;
user_with_most_friends   = LIMIT user_by_friends_count $NUM_USERS;


-- profiles
full_profile = LOAD '$PROFILE' AS (rsrc:chararray, id:long, scraped_at:long, name:chararray, url:chararray, location:chararray, description:chararray, time_zone:chararray, utc_offset:chararray);
profile = FOREACH full_profile GENERATE id, name, url, location, description, time_zone; -- (2015,josh,http://sciencevsromance.net,iPhone: 47.659470,-122.096268,hello there)

user_data_with_most_followers = JOIN user_with_most_followers BY id, full_profile BY id;
DUMP user_data_with_most_followers;
user_data_with_most_friends   = JOIN user_with_most_friends BY id, full_profile BY id;

rmf $MOST_FOLLOWERS;
STORE user_data_with_most_followers INTO '$MOST_FOLLOWERS' ;
rmf $MOST_FRIENDS;
STORE user_data_with_most_friends   INTO '$MOST_FRIENDS'   ;



