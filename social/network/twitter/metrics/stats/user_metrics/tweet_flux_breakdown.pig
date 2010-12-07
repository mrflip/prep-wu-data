tweet         = LOAD '$TWEET'         AS (rsrc:chararray, twid:long,      crat:long,              uid:long,    sn:chararray,            sid:long,          in_reply_to_uid:long, in_reply_to_sn:chararray,     in_reply_to_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
hashtag       = LOAD '$HASHTAG'       AS (rsrc:chararray, text:chararray, twid:long,              uid:long,    crat:long);                                                           
smiley        = LOAD '$SMILEY'        AS (rsrc:chararray, text:chararray, twid:long,              uid:long,    crat:long);                                                           
tweet_url     = LOAD '$URL'           AS (rsrc:chararray, text:chararray, twid:long,              uid:long,    crat:long);                                                           

cut_tweet  = FOREACH tweet     GENERATE uid;
cut_hash   = FOREACH hashtag   GENERATE uid;
cut_smile  = FOREACH smiley    GENERATE uid;
cut_url    = FOREACH tweet_url GENERATE uid;

cogrpd     = COGROUP cut_tweet BY uid, cut_hash BY uid, cut_smile BY uid, cut_url BY uid;
flux_types = FOREACH cogrpd GENERATE
                 group            AS uid,
                 COUNT(cut_tweet) AS tw_o,
                 COUNT(cut_hash)  AS hsh_o,
                 COUNT(cut_smile) AS sm_o,
                 COUNT(cut_url)   AS url_o
             ;

STORE flux_types INTO '$FLUX';

-- flux_breakdown = LOAD '$FLUX' AS (user_id:long, tweets_out:long, hashtags_out:long, smileys_out:long, urls_out:long);
