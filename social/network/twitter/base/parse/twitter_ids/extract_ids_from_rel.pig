--
-- Extract from a_follows_b a flat list of every id
--
%default RAW_REL_IDS_FILE '/tmp/all_seen_users/raw_rel_ids' -- intermediate data products need to go to /tmp
        
a_follows_b = LOAD '$REL' AS (rsrc:chararray, user_a_id:long, user_b_id:long);
fo_i_ids    = FOREACH a_follows_b GENERATE user_a_id AS uid:long;
fo_o_ids    = FOREACH a_follows_b GENERATE user_b_id AS uid:long;
all_rel_ids = UNION fo_i_ids, fo_o_ids;
uniq_ids    = DISTINCT all_rel_ids;

rmf $RAW_REL_IDS_FILE;
STORE uniq_ids INTO '$RAW_REL_IDS_FILE';
