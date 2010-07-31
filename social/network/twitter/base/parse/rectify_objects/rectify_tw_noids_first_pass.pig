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

rmf $FAIL;
STORE noids INTO '$FAIL';

rmf $TWFIXD;
STORE rectified INTO '$TWFIXD';
