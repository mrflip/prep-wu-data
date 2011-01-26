tweet        = LOAD '$TWEET' AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, in_re_twid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float);
tweeter      = FOREACH tweet GENERATE uid AS uid, sn AS sn:chararray;
with_replies = FILTER  tweet BY ((in_reply_to_uid IS NOT NULL) OR (in_reply_to_sn IS NOT NULL));
receiver     = FOREACH with_replies GENERATE in_reply_to_uid AS uid, in_reply_to_sn AS sn:chararray;
mapping      = UNION tweeter, receiver;
uniq_map     = DISTINCT mapping;

STORE uniq_map INTO '$OUT';
