--
-- Load Word Stats using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  '/tmp/streamed/global_word_stats_json'
%default TABLE 'soc_net_tw_word_stats'

data     = LOAD '$DATA' AS (row_key:chararray, word_stats_json:chararray);
STORE data INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$TODAY:word_stats_json');
