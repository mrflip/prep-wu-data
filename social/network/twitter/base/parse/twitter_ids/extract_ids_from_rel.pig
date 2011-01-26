a_follows_b = LOAD '$AFB' AS (rsrc:chararray, user_a_id:long, user_b_id:long);
fo_i_ids    = FOREACH a_follows_b GENERATE user_a_id AS uid:long;
fo_o_ids    = FOREACH a_follows_b GENERATE user_b_id AS uid:long;
all_rel_ids = UNION fo_i_ids, fo_o_ids;
uniq_ids    = DISTINCT all_rel_ids;

STORE uniq_ids INTO '$OUT';
