--
-- Load Word Usage using pig and HBase TableOutputFormat
--
register '/home/travis/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';
register '/usr/local/share/pig/build/pig-0.8.0-SNAPSHOT-core.jar';

%default TABLE 'soc_net_tw_word_usage'

data        = LOAD '$DATA' AS (uid:long);
cut_fields  = FOREACH json_slinks GENERATE user_id AS key,;
STORE cut_fields INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$TODAY:strong_links_json');
