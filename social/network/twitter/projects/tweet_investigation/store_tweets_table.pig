--
-- Store tweets into hbase so we can test how well we can query
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/home/jacob/Programming/hbase_bulkloader/lib/joda-time-1.6.2.jar';
register '/usr/lib/hbase/hbase.jar';
register '/usr/lib/hbase/lib/zookeeper.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default TWIDS '/tmp/tweet/hbase_format'
%default TABLE 'soc_net_tw_tweet'

DEFINE CONVERT com.infochimps.hadoop.pig.datetime.StringFormatToUnix();

twids = LOAD '$TWIDS' AS (row_key:chararray, column_family:chararray, column_name:chararray, column_value:chararray, timestamp:long);

STORE twids INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
