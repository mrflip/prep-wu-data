id_table = LOAD '$TABLE'  AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, prot:int, followers:int, friends:int, statuses:int, favs:int, crat:long, sid:long, isfull:int, health:chararray);
atsigns  = LOAD '$ATS'    AS (rsrc:chararray, user_a_id:long, user_b_id:long, rel_type:chararray, twid:long, crat:long, user_b_sn:chararray, rel_tw_id:long);

-- rectify atsigns
mapping      = FOREACH id_table GENERATE uid, sn;
ats_joined   = JOIN atsigns BY user_b_sn, mapping BY sn;
ats_filtered = FILTER ats_joined BY mapping::uid IS NOT NULL; -- naughty naughty
a_atsigns_b  = FOREACH ats_filtered GENERATE
                    'a_atsigns_b'       AS rsrc,
                    atsigns::user_a_id  AS user_a_id,
                    mapping::uid        AS user_b_id,
                    atsigns::rel_type   AS rel_type,
                    atsigns::twid       AS twid,
                    atsigns::crat       AS crat,
                    atsigns::user_b_sn  AS user_b_sn,
                    atsigns::rel_tw_id  AS rel_tw_id
               ;

a_atsigns_b_d = DISTINCT a_atsigns_b;

rmf $AATSB;
STORE a_atsigns_b_d INTO '$AATSB';
