%default TWNOID '/data/sn/tw/fixd/objects/tweet-noid'
%default TABLE  '/data/sn/tw/fixd/users_table'
%defailt TWFIXD '/data/sn/tw/fixd/tweets_rectified'
        
tw_noid   = LOAD '$TWNOID' AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was_stw:int);
mapping   = LOAD '$TABLE'  AS (sn:chararray, uid:long, sid:long);

joined    = JOIN mapping BY sn, tw_noid BY sn;
fixed_ids = FOREACH joined GENERATE
                "tweet"                  AS rsrc,
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

joined_again = JOIN mapping BY sn, fixed_ids BY in_reply_to_sn;
rectified    = FOREACH joined_again GENERATE
                   "tweet"                    AS rsrc,
                   fixed_ids::twid            AS twid,
                   fixed_ids::crat            AS crat,
                   fixed_ids::uid             AS uid,
                   fixed_ids::sn              AS sn,
                   fixed_ids::sid             AS sid,
                   mapping::uid               AS in_reply_to_uid,
                   fixed_ids::in_reply_to_sn  AS in_reply_to_sn,
                   fixed_ids::in_reply_to_sid AS in_reply_to_sid,
                   fixed_ids::text            AS text,
                   fixed_ids::src             AS src,
                   fixed_ids::iso             AS iso,
                   fixed_ids::lat             AS lat,
                   fixed_ids::lon             AS lon,
                   fixed_ids::was_stw         AS was_stw
               ;

rmf
