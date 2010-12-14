--
-- Returns all a_follows_b objects that are only in A
--
version_a = LOAD '$A' AS (rsrc:chararray, user_a_id:long, user_b_id:long);
version_b = LOAD '$B' AS (rsrc:chararray, user_a_id:long, user_b_id:long);

version_a_cut = FOREACH version_a GENERATE user_a_id AS user_a_id, user_b_id AS user_b_id;
version_b_cut = FOREACH version_b GENERATE user_a_id AS user_a_id, user_b_id AS user_b_id;
together      = COGROUP version_a_cut BY (user_a_id, user_b_id) INNER, version_b_cut BY (user_a_id, user_b_id);
only_in_a     = FILTER together BY IsEmpty(version_b_cut);
only_in_a_flat = FOREACH only_in_a GENERATE FLATTEN(group) AS (user_a_id, user_b_id); 

STORE only_in_a_flat INTO '$OUT';
