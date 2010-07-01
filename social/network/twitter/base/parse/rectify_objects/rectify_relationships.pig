%default TABLE  '/data/sn/tw/fixd/users_table'
%default ATS    '/data/sn/tw/fixd/objects/a_atsigns_b_name'
%default RTS    '/data/sn/tw/fixd/objects/a_retweets_b_name'
%default AATSB  '/data/sn/tw/fixd/objects/a_atsigns_b'
%default ARTB   '/data/sn/tw/fixd/objects/a_retweets_b'
        
mapping  = LOAD '$TABLE'  AS (sn:chararray, uid:long, sid:long);
atsigns  = LOAD '$ATS'    AS (rsrc:chararray, user_a_id:long, user_b_name:chararray, twid:long);
retweets = LOAD '$ATS'    AS (rsrc:chararray, user_a_id:long, user_b_name:chararray, twid:long, plz_flag:int);

-- rectify atsigns
ats_joined  = JOIN atsigns BY user_b_name, mapping BY sn;
a_atsigns_b = FOREACH ats_joined GENERATE
                  "a_atsigns_b"      AS rsrc,
                  atsigns::user_a_id AS user_a_id,
                  mapping::uid       AS user_b_id,
                  atsigns::twid      AS twid
              ;
rmf $AATSB;
STORE a_atsigns_b INTO '$AATSB';

-- rectify retweets
rts_joined   = JOIN retweets BY user_b_name, mapping BY sn;
a_retweets_b = FOREACH ats_joined GENERATE
                  "a_retweets_b"      AS rsrc,
                  retweets::user_a_id AS user_a_id,
                  mapping::uid        AS user_b_id,
                  retweets::twid      AS twid
              ;
rmf $ARTB;
STORE a_retweets_b INTO '$ARTB';
