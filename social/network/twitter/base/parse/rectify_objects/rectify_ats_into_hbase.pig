register /home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar
register /usr/lib/hbase/lib/jline-0.9.94.jar
register /usr/lib/hbase/lib/guava-r05.jar


%default ATS_TABLE   'soc_net_tw_a_rel_b'
%default TWUID_TABLE 'soc_net_tw_twitter_user'
        
-- export PIG_CLASSPATH=/usr/lib/hbase/lib/jline-0.9.94.jar:/usr/lib/hbase/lib/guava-r05.jar:/usr/lib/hbase/lib/commons-lang-2.5.jar:/usr/lib/hbase/hbase.jar:/usr/lib/hbase/hbase-tests.jar:/usr/local/share/pig/pig-0.8.0-core.jar
-- pig -p TABLE=a_rel_b_20110128 -p OUT=/tmp/pagerank/201102/assemble-multigraph-0 assemble_multigraph_hbase.pig
data         = LOAD '$TWUID_TABLE' USING com.infochimps.hbase.pig.HBaseStorage('info:screen_name', '-loadKey') AS (user_id:int, screen_name:chararray);
a_atsigns_bn = LOAD '$ATS' AS (rsrc:chararray, user_a_id:long, user_b_id:long, rel_type:chararray, twid:long, crat:long, user_b_sn:chararray, rel_tw_id:long);

filtered     = FILTER a_atsigns_bn BY user_b_sn IS NOT NULL:
ats_joined   = JOIN filtered BY user_b_sn, data BY screen_name;
ats_filtered = FILTER ats_joined BY data::user_id IS NOT NULL; -- naughty naughty
a_atsigns_b  = FOREACH ats_filtered GENERATE
                    filtered::user_a_id AS user_a_id,
                    data::user_id       AS user_b_id,
                    filtered::rel_type  AS rel_type,
                    filtered::twid      AS tweet_id,
                    filtered::crat      AS created_at,
                    filtered::user_b_sn AS user_b_sn,
                    filtered::rel_tw_id AS rel_tw_id
               ;

generated = FOREACH a_atsigns_b {
              row_key   = CONCAT(CONCAT(user_a_id, ':'), user_b_id);
              col_fam   = (rel_type == 're' ? 'reply' : (rel_type == 'me' ? 'mention' : (rel_type == 'rt' ? 'retweet' : 'unknown')));
              json_meta = com.infochimps.hadoop.pig.TupleToJson(created_at, user_b_sn, rel_tw_id, 'created_at,user_b_sn,rel_tw_id');
              GENERATE
                row_key   AS row_key,
                col_fam   AS col_fam,
                tweet_id  AS col_name,
                json_meta AS col_val
              ;
            };

STORE generated INTO '$ATS_TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();

