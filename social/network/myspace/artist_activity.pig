-- Here are the things a band can do:

-- A) A band can add a show
-- B) A band can add a song, or many songs, to their page
-- C) Everything a normal user can do

-- And that's the caveat, a band is the exact same as any other user. There is no special flag.

-- Here's what we want to look for:  band_show_added and song_upload, for now.
-- Questions:
-- Is it okay to have deanonymized band information? Is a band entitled to the same privacy
-- rights as a real person? What if the band is a only one person?

-- defaults
%default OUTPUT '/data/fixd/social/network/myspace/artist_activities'           ;
%default USER   '/data/fixd/social/network/myspace/objects/myspace_person' ;
%default UPLOAD '/data/fixd/social/network/myspace/objects/song_upload' ;
%default SHOW   '/data/fixd/social/network/myspace/objects/band_show_added' ;

-- libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;

full_user     = LOAD '$USER' AS (rsrc:chararray, id:long, firstname:chararray, lastname:chararray, username:chararray, lat:float, lon:float, country:chararray, locality:chararray, zip_code:chararray, friend_count:long, link:chararray) ;
user 	      = FOREACH full_user GENERATE id, firstname, lastname, lat, lon, country, locality, friend_count;
user_group    = GROUP user BY id;
distinct_user_all = FOREACH user_group GENERATE group AS id, FLATTEN(user.friend_count);
user_sample = LIMIT distinct_user_all 100; DUMP user_sample ;
-- distinct_user = FOREACH distinct_user_all_zips GENERATE $0, $1;
-- distinct_user_with_zip = FILTER distinct_user BY zip_code MATCHES '[0-9]{5}(-[0-9]{4})?';
-- grouped_zip   = GROUP distinct_user_with_zip BY zip_code;
-- zip_count     = FOREACH grouped_zip GENERATE group AS zip_code, COUNT(distinct_user_with_zip);
-- rmf $OUTPUT
-- STORE zip_count INTO '$OUTPUT';
