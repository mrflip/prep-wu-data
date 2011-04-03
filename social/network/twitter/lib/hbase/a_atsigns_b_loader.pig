register /home/jacob/Progamming/hbase_bulkloader/build/hbase_bulkloader.jar
register /usr/lib/hbase/lib/jline-0.9.94.jar
register /usr/lib/hbase/lib/guava-r05.jar

%default TABLE 'soc_net_tw_a_rel_b'
%default AATSB 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/a_atsigns_b'
        
data = LOAD 'AATSB' AS (rsrc:chararray, user_a_id:chararray, user_b_id:chararray, rel_type:chararray, tweet_id:long, created_at:long, user_b_sn:chararray, rel_tw_id:long);
filtered  = FILTER data BY rel_type IS NOT NULL;
generated = FOREACH filtered {
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
STORE generated INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
