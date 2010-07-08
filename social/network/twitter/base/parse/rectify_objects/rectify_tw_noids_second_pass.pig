--
-- Now we need to take the rectified tweets and rectify the in reply to user ids properly
--
-- 3 stores is annoying

%default TABLE   '/data/sn/tw/fixd/users_table'
%default TWFIXD  '/data/sn/tw/fixd/objects/tweet-rectified'
%default TWGOOD  '/data/sn/tw/fixd/objects/tweet-good'
%default TWRFIXD '/data/sn/tw/fixd/objects/tweet-replies-rectified'
%default TWRBAD  '/data/sn/tw/fixd/objects/tweet-no-reply-id'
        
-- these are rectified tweets that have a good user id
tw_rect = LOAD '$TWFIXD' AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was_stw:int);
mapping = LOAD '$TABLE'  AS (sn:chararray, uid:long, sid:long);

-- these tweets are both rectified and are not in reply to anyone, store them
not_replies = FILTER tw_rect BY in_reply_to_sn IS NULL;
rmf $TWGOOD;
STORE not_replies INTO '$TWGOOD';

-- these tweets are rectified on user id but are in reply to people, need to rectify in_reply_to_uid
replies     = FILTER tw_rect BY in_reply_to_sn IS NOT NULL;
joined      = JOIN replies BY in_reply_to_sn, mapping BY sn;
rectified   = FOREACH joined GENERATE
                  tw_rect::rsrc            AS rsrc,
                  tw_rect::twid            AS twid,
                  tw_rect::crat            AS crat,
                  tw_rect::uid             AS uid,
                  tw_rect::sn              AS sn,
                  tw_rect::sid             AS sid,
                  mapping::uid             AS in_reply_to_uid,
                  tw_rect::in_reply_to_sn  AS in_reply_to_sn,
                  tw_rect::in_reply_to_sid AS in_reply_to_sid,
                  tw_rect::text            AS text,
                  tw_rect::src             AS src,
                  tw_rect::iso             AS iso,
                  tw_rect::lat             AS lat,
                  tw_rect::lon             AS lon,
                  tw_rect::was_stw         AS was_stw
              ;

SPLIT rectified INTO no_reply_id IF in_reply_to_uid IS NULL, with_reply_id IF in_reply_to_uid IS NOT NULL;

rmf $TWRBAD;
STORE no_reply_id INTO '$TWRBAD';

rmf $TWRFIXD;
STORE with_reply_id INTO '$TWRFIXD';
