%default TWNOID '/data/sn/tw/fixd/objects/tweet-noid'
%default TABLE  '/data/sn/tw/fixd/users_table'
%default TWFIXD '/data/sn/tw/fixd/objects/tweet-rectified'
%default FAIL   '/data/sn/tw/rawd/to_scrape/tweet-noid'
        
tw_noid   = LOAD '$TWNOID' AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was_stw:int);
mapping   = LOAD '$TABLE'  AS (sn:chararray, uid:long, sid:long);

-- first rectify user ids
joined    = JOIN mapping BY sn FULL OUTER, tw_noid BY sn;
fixed_ids = FOREACH joined
            {
                rsrc_name = (mapping::uid IS NOT NULL ? "tweet" : "tweet-noid");
                GENERATE
                    rsrc_name                AS rsrc,
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

-- store misses on disk
noids = FILTER fixed_ids BY rsrc == "tweet-noid";
rmf $FAIL;
STORE noids INTO '$FAIL'

-- rectify in reply to uids        
good_tweets  = FILTER fixed_ids BY rsrc == "tweet";
joined_again = JOIN mapping BY sn FULL OUTER, good_tweets BY in_reply_to_sn;
rectified    = FOREACH joined_again GENERATE
                   good_tweets::rsrc            AS rsrc,
                   good_tweets::twid            AS twid,
                   good_tweets::crat            AS crat,
                   good_tweets::uid             AS uid,
                   good_tweets::sn              AS sn,
                   good_tweets::sid             AS sid,
                   mapping::uid                 AS in_reply_to_uid, -- this can be nil ...
                   good_tweets::in_reply_to_sn  AS in_reply_to_sn,
                   good_tweets::in_reply_to_sid AS in_reply_to_sid,
                   good_tweets::text            AS text,
                   good_tweets::src             AS src,
                   good_tweets::iso             AS iso,
                   good_tweets::lat             AS lat,
                   good_tweets::lon             AS lon,
                   good_tweets::was_stw         AS was_stw
               ;

rmf $TWFIXD;
STORE rectified INTO '$TWFIXD';
