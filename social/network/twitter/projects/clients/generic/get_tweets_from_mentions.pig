%default ME 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/client/buster_keaton_mentions'
%default TWT 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/20100806/tweet-merged'
        
a_atsigns_b = LOAD '$ME' AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    crat:long);
tweet       = LOAD '$TWT' AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float);
a_atsigns_b_c = FOREACH a_atsigns_b GENERATE twid;

extracted   = JOIN tweet BY twid, a_atsigns_b_c BY twid USING 'replicated';
extracted_f = FOREACH extracted GENERATE
                tweet::rsrc,
                tweet::twid,
                tweet::crat,
                tweet::uid,
                tweet::sn,
                tweet::sid,
                tweet::in_re_uid,
                tweet::in_re_sn,
                tweet::in_re_sid,
                tweet::in_re_twid,
                tweet::text,
                tweet::src,
                tweet::iso,
                tweet::lat,
                tweet::lon
              ;
STORE extracted_f INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/client/buster_keaton_me_tweets';
