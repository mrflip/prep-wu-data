%default TWNOID  '/data/sn/tw/fixd/objects/tweet-noid'
%default TABLE   '/data/sn/tw/fixd/objects/twitter_user_id'
%default TWFIXD  '/data/sn/tw/fixd/objects/tweet-rectified'
%default FAIL    '/data/sn/tw/rawd/to_scrape/tweet-noid'
        
tw_noid         = LOAD '$TWNOID' AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, in_reply_to_twid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was_stw:int);
twitter_user_id = LOAD '$TABLE'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:long, friends:long, statuses:long, favourites:long, crat:long, sid:long, is_full:int, health:chararray);

-- first join against user id table using screen name as key
mapping   = FOREACH twitter_user_id GENERATE uid, sn;
joined    = JOIN mapping BY sn, tw_noid BY sn;
fixed_ids = FOREACH joined
            {
                rsrc = ( mapping::uid IS NULL ? 'tweet-noid' : 'tweet');
                GENERATE
                    rsrc                     AS rsrc,
                    tw_noid::twid            AS twid,
                    tw_noid::crat            AS crat,
                    mapping::uid             AS uid,
                    tw_noid::sn              AS sn,
                    tw_noid::sid             AS sid,
                    tw_noid::in_reply_to_uid AS in_reply_to_uid,
                    tw_noid::in_reply_to_sn  AS in_reply_to_sn,
                    tw_noid::in_reply_to_sid AS in_reply_to_sid,
                    tw_noid::text            AS text,
                    tw_noid::src             AS src,
                    tw_noid::iso             AS iso,
                    tw_noid::lat             AS lat,
                    tw_noid::lon             AS lon,
                    tw_noid::was_stw         AS was_stw
                ;
            };

SPLIT fixed_ids INTO noids IF rsrc == 'tweet-noid', rectified IF rsrc == 'tweet';


not_replies = FILTER rectified BY in_reply_to_sn IS NULL;
-- store into elasticsearch



replies     = FILTER rectified BY in_reply_to_sn IS NOT NULL;
joined      = JOIN replies BY in_reply_to_sn, mapping BY sn;
rectified   = FOREACH joined GENERATE
                  replies::rsrc            AS rsrc,
                  replies::twid            AS twid,
                  replies::crat            AS crat,
                  replies::uid             AS uid,
                  replies::sn              AS sn,
                  replies::sid             AS sid,
                  mapping::uid             AS in_reply_to_uid,
                  replies::in_reply_to_sn  AS in_reply_to_sn,
                  replies::in_reply_to_sid AS in_reply_to_sid,
                  replies::text            AS text,
                  replies::src             AS src,
                  replies::iso             AS iso,
                  replies::lat             AS lat,
                  replies::lon             AS lon,
                  replies::was_stw         AS was_stw
              ;

SPLIT rectified INTO no_reply_id IF in_reply_to_uid IS NULL, with_reply_id IF in_reply_to_uid IS NOT NULL;

