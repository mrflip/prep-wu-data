%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'                   
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/hadoop_book'
%default ICS_ID    '15748351L' -- @infochimps
%default HDP_ID    '19041500L' -- @hadoop
%default CLD_ID    '16134540L' -- @cloudera
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;


-- SCHEMAS
a_follows_b              = LOAD '$TW_OBJ_PATH/a_follows_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_atsigns_b              = LOAD '$TW_OBJ_PATH/a_atsigns_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    crat:long);
tweet                    = LOAD '$TW_OBJ_PATH/tweet'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
twitter_user             = LOAD '$TW_OBJ_PATH/twitter_user'          	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);                                                                             

a_follows_b_s            = LOAD '$NBRHOOD_PATH/a_follows_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_atsigns_b_s            = LOAD '$NBRHOOD_PATH/a_atsigns_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
tweet_s                  = LOAD '$NBRHOOD_PATH/tweet'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
n1                       = LOAD '$NBRHOOD_PATH/n1'                 	AS (user_id:long);
twitter_user_s           = LOAD '$NBRHOOD_PATH/twitter_user'          	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);                                                                             

--
-- Find all nodes in the in or out 1-neighborhood (at radius 1 from our seed)
--

-- Find all atsigns that = originate in n1
atsigns_from_n1_j        = JOIN a_atsigns_b BY user_a_id, n1 BY user_id using 'replicated';
atsigns_from_n1_g        = FOREACH atsigns_from_n1_j GENERATE a_atsigns_b::user_a_id AS user_a_id, a_atsigns_b::user_b_id AS user_b_id;
atsigns_from_n1          = FILTER atsigns_from_n1_g BY (user_a_id != user_b_id);
-- Among those atsigns, find those that terminate in n1 as well
atsigns_within_n1_j      = JOIN atsigns_from_n1 BY user_b_id, n1 BY user_id using 'replicated';
atsigns_within_n1_p      = FOREACH atsigns_within_n1_j GENERATE user_a_id, user_b_id;
atsigns_within_n1_c      = GROUP atsigns_within_n1_p BY (user_a_id, user_b_id) PARALLEL 1;
atsigns_within_n1        = FOREACH atsigns_within_n1_c GENERATE group.user_a_id AS user_a_id, group.user_b_id AS user_b_id, COUNT(atsigns_within_n1_p) AS num;
-- Save the result
rmf                         $NBRHOOD_PATH/n1atsigns
STORE atsigns_within_n1 INTO '$NBRHOOD_PATH/n1atsigns';

--
-- Find all follows that originate in n1
-- 
follows_from_n1_j        = JOIN a_follows_b BY user_a_id, n1 BY user_id using 'replicated';
follows_from_n1_g        = FOREACH follows_from_n1_j GENERATE a_follows_b::user_a_id AS user_a_id, a_follows_b::user_b_id AS user_b_id;
follows_from_n1          = FILTER follows_from_n1_g BY (user_a_id != user_b_id);
-- Among those follows, find those that terminate in n1 as well
follows_within_n1_j      = JOIN follows_from_n1 BY user_b_id, n1 BY user_id using 'replicated';
follows_within_n1_p      = FOREACH follows_within_n1_j GENERATE user_a_id, user_b_id;
follows_within_n1_c      = GROUP follows_within_n1_p BY (user_a_id, user_b_id) PARALLEL 1;
follows_within_n1        = FOREACH follows_within_n1_c GENERATE group.user_a_id AS user_a_id, group.user_b_id AS user_b_id, COUNT(follows_within_n1_p) AS num;
-- Save the result
rmf                         $NBRHOOD_PATH/n1follows
STORE follows_within_n1 INTO '$NBRHOOD_PATH/n1follows';


-- /data/sn/tw/projects/explorations/hadoop_book/a_atsigns_b              	         791551	       773.0 KB
-- /data/sn/tw/projects/explorations/hadoop_book/a_follows_b              	        2157915	         2.1 MB
-- /data/sn/tw/projects/explorations/hadoop_book/n1                       	       19922488	        19.0 MB
-- /data/sn/tw/projects/explorations/hadoop_book/n1edges                  	         222814	       217.6 KB
-- /data/sn/tw/projects/explorations/hadoop_book/tweet                    	       20217372	        19.3 MB
-- /data/sn/tw/projects/explorations/hadoop_book/twitter_user             	        1715575	         1.6 MB
