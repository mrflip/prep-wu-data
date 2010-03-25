-- defaults
%default SONG         '/data/fixd/social/network/myspace/objects/song_upload'    ;
%default SHOW         '/data/fixd/social/network/myspace/objects/band_show_added';
%default OUTPUT_DIR   '/data/fixd/social/network/myspace/artist_activities'      ;
%default OUTPUT       '$OUTPUT_DIR/artist_activity_by_day'                       ;
%default RECENT_DATE  '.*2010.*' ;

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;


/*

This WOULD work, BUT:
     The currently parsed data doesn't contain artist names. object_author is nil. Bah.
     
*/

-- get songs
full_song = LOAD '$SONG' AS (rsrc:chararray, created_at:chararray, activity_id:long, user_id:long, text:chararray, category:chararray, object_title:chararray, object_author:chararray, target_title:chararray, source:chararray);
song_info = FOREACH full_song GENERATE org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 8) AS created_at, object_title, object_author;
recent_song_info = FILTER song_info BY created_at MATCHES '$RECENT_DATE';

-- get shows
full_show = LOAD '$SHOW' AS (rsrc:chararray, created_at:chararray, activity_id:long, user_id:long, text:chararray, category:chararray, object_title:chararray, object_author:chararray, target_title:chararray, source:chararray);
show_info = FOREACH full_show GENERATE org.apache.pig.piggybank.evaluation.string.SUBSTRING(created_at, 0, 8) AS created_at, object_title, object_author;
recent_show_info = FILTER show_info BY created_at MATCHES '$RECENT_DATE';

activity = UNION recent_song_info, recent_show_info;
activity_group = GROUP activity BY (created_at, object_title, object_author);
activity_count = FOREACH activity_group GENERATE group.created_at, group.object_title, group.object_author, COUNT(activity);

rmf $OUTPUT;
STORE activity_count INTO '$OUTPUT';
