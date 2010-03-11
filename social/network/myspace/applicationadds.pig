
/* From

activity

    :created_at,
    :activity_id,
    :person_id,
    :text,
    :category,
    :object_title,
    :object_author,
    :target_title,
    :source

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
%default APPADD       '/data/fixd/social/network/myspace/objects/application_add' ;
%default USER         '/data/fixd/social/network/myspace/objects/myspace_person' ;

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

-- get status update
full_appadd = LOAD '$APPADD' AS (rsrc:chararray, created_at:long, activity_id:long, person_id:long, text:chararray, category:chararray, object_title:chararray, object_author:chararray, target_title:chararray, source:chararray) ;
appadd_item = FOREACH full_appadd GENERATE created_at, person_id, object_title, object_author, target_title;

-- get user
full_user = LOAD '$USER' AS (rsrc:chararray, person_id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;
user_item = FOREACH full_user GENERATE person_id, zip_code ;

record = JOIN appadd_item BY person_id, user_item BY person_id ;

record_item = FOREACH record GENERATE created_at, user_item::person_id, zip_code, object_title, object_author, target_title ;

STORE record_item INTO '/data/fixd/social/network/myspace/applicationadds_by_timeANDzip' ;
