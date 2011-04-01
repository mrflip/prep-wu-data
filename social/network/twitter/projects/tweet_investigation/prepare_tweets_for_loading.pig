register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/home/jacob/Programming/hbase_bulkloader/lib/joda-time-1.6.2.jar';
register '/usr/lib/hbase/hbase.jar';
register '/usr/lib/hbase/lib/zookeeper.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default TWEET '/tmp/streamed/tweet'

DEFINE CONVERT com.infochimps.hadoop.pig.datetime.StringFormatToUnix();

tweet     = LOAD '$TWEET' AS (rsrc:chararray, tweet_id:long, created_at:chararray, user_id:long, screen_name:chararray, search_id:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, text:chararray, source:chararray, lang:chararray, lat:float, lng:float, retweeted_count:int, rt_of_user_id:int, rt_of_screen_name:chararray, rt_of_tweet_id:long, contributors:chararray);
cut_tweet = FOREACH tweet GENERATE user_id AS row_key, 'tweet_ids' AS column_family, tweet_id AS column_name, '0' AS column_value, CONVERT(created_at) AS timestamp;

STORE cut_tweet INTO '$HDFS/$OUT';
