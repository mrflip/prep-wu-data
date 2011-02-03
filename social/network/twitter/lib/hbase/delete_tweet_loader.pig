--
-- Load Deleted Tweets using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/delete_tweet'
%default TABLE 'soc_net_tw_delete_tweet'
%default CF    'base'

data     = LOAD '$DATA' AS (rsrc:chararray, twid:long, created_at:long, user_id:long, screen_name:chararray);
cut_data = FOREACH data GENERATE twid AS key, twid AS tweet_id, created_at, user_id, screen_name;
STORE cut_data INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:tweet_id $CF:created_at $CF:user_id $CF:screen_name');
