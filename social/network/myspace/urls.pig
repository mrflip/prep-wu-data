/* From
share_item (just like any other activity)

    :created_at,
    :activity_id,
    :person_id,
    :text,
    :category,
    :object_title,
    :object_author,
    :target_title,
    :source

*/


-- defaults
%default SHAREITEM   '/data/fixd/social/network/myspace/objects/share_item' ;
%default OUTPUT      '/data/fixd/social/myspace/shared_urls' ; 

-- load libraries
REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar ;


full_share_item = LOAD '$SHAREITEM' AS (rsrc:chararray, created_at:long, activity_id:long, person_id:long, text:chararray, category:chararray, object_title:chararray, target_title:chararray, source:chararray ) ;
url_item = FOREACH full_share_item GENERATE created_at, person_id, object_title, target_title, source;
STORE url_item INTO '$OUTPUT';
