--
-- Store tweets into hbase so we can test how well we can query
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/home/jacob/Programming/hbase_bulkloader/lib/joda-time-1.6.2.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';
register '/usr/local/share/pig/build/pig-0.8.0-SNAPSHOT-core.jar';

%default TABLE 'test_sparse_tweets'

twids  = LOAD '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('twids: ', '-loadKey') AS (user_id:chararray, twids:bag { pair:tuple (tweet_id:long, garbage:chararray) });
counts = FOREACH twids GENERATE user_id, COUNT(twids) AS num_tweets;

STORE counts INTO '$HDFS/$OUT';
