register /home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar
register /usr/lib/hbase/lib/jline-0.9.94.jar
register /usr/lib/hbase/lib/guava-r05.jar

%default TABLE 'soc_net_tw_a_rel_b'
%default AFOB 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/a_follows_b'
        
data = LOAD '$AFOB' AS (rsrc:chararray, user_a_id:chararray, user_b_id:chararray);

a_follows_b = FOREACH data {
                row_key   = CONCAT(CONCAT(user_a_id, ':'), user_b_id);
                GENERATE
                  row_key  AS row_key,
                  'follow' AS col_fam,
                  'ab'     AS col_name,
                  '1'      AS col_val
                ;
              };

b_follows_a = FOREACH data {
                row_key   = CONCAT(CONCAT(user_b_id, ':'), user_a_id);
                GENERATE
                  row_key  AS row_key,
                  'follow' AS col_fam,
                  'ba'     AS col_name,
                  '1'      AS col_val
                ;
              };

generated = UNION a_follows_b, b_follows_a;
STORE generated INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
