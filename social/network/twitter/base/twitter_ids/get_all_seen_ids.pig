%default A_FOLLOWS_B_FILE   '/data/sn/tw/fixd/objects/a_follows_b,/data/sn/tw/rawd/20100628-20100710/unspliced/a_follows_b'
%default A_REPLIES_B_N_FILE '/data/sn/tw/rawd/20100628-20100710/unspliced/a_replies_b_name'
%default RAW_IDS_FILE      '/data/sn/tw/rawd/20100628-20100710/uniqd/raw_ids'

a_follows_b    = LOAD '$A_FOLLOWS_B_FILE'   AS (rsrc:chararray, user_a:long, user_b:long);
a_replies_b_n  = LOAD '$A_REPLIES_B_N_FILE' AS (rsrc:chararray, user_a:long, user_b_sn:chararray);

src_nodes    = FOREACH a_follows_b   GENERATE user_a AS user_id:long;
dest_nodes   = FOREACH a_follows_b   GENERATE user_b AS user_id:long;
repl_nodes   = FOREACH a_replies_b_n GENERATE user_a AS user_id:long;

all_nodes    = UNION src_nodes, dest_nodes, repl_nodes;
uniq_nodes   = DISTINCT all_nodes;

rmf                    $RAW_IDS_FILE
STORE uniq_nodes INTO '$RAW_IDS_FILE';
