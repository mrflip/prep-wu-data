--
-- Load Strong Links using pig and HBase TableOutputFormat
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default TABLE 'soc_net_tw_stronglinks'
%default JSONIZE_SCRIPT '/home/jacob/Programming/infochimps-data/social/network/twitter/metrics/stats/user_metrics/jsonize_strong_links.rb'

data        = LOAD '$DATA' AS (uid:long, screen_name:chararray, strong_links:chararray);
json_slinks = STREAM data THROUGH `$JSONIZE_SCRIPT --map` AS (user_id:long, strong_links_json:chararray);
cut_fields  = FOREACH json_slinks GENERATE user_id AS key, strong_links_json;
STORE cut_fields INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$TODAY:strong_links_json');
