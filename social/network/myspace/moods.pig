/* From

mood
    :created_at,
    :person_id,
    :text

person

    :person_id,
    :firstname,
    :lastname,
    :username,
    :lat,
    :lon,
    :country,
    :locality,
    :zip_code,
    :friend_count,
    :link

    
*/


-- defaults
%default MOOD   '/data/fixd/social/network/myspace/objects/myspace_mood' ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- get mood
full_mood = LOAD '$MOOD' AS (rsrc:chararray, created_at:long, person_id:long, text:chararray) ;
mood_item = FOREACH full_mood GENERATE created_at, person_id, text;
mood_sample = LIMIT mood_item 10; DUMP mood_sample ;

-- get user
full_user = LOAD '$USER' AS (rsrc:chararray, person_id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;
user_item = FOREACH full_user GENERATE person_id, zip_code;
user_sample = LIMIT user_item 10; DUMP user_sample ;

record = JOIN mood_item BY person_id, user_item BY person_id ;
record_sample = LIMIT record 10; DUMP record_sample ;

record_item = FOREACH record GENERATE created_at, user_item::person_id, zip_code, text ;
record_item_sample = LIMIT record_item 10; DUMP record_item_sample ;


STORE record_item INTO '/data/fixd/social/network/myspace/moods_by_timeANDzip' ;
