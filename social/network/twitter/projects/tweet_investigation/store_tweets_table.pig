--
-- Store tweets into hbase so we can test how well we can query
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/home/jacob/Programming/hbase_bulkloader/lib/joda-time-1.6.2.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';
register '/usr/local/share/pig/build/pig-0.8.0-SNAPSHOT-core.jar';

%default TWEET '/tmp/streamed/tweet'
%default TABLE 'test_sparse_tweets'

DEFINE CONVERT com.infochimps.hadoop.pig.datetime.StringFormatToUnix();

tweet     = LOAD '$TWEET' AS (rsrc:chararray, tweet_id:long, created_at:chararray, user_id:long, screen_name:chararray, search_id:long, in_reply_to_uid:long, in_reply_to_sn:chararray, in_reply_to_sid:long, text:chararray, source:chararray, lang:chararray, lat:float, lng:float, retweeted_count:int, rt_of_user_id:int, rt_of_screen_name:chararray, rt_of_tweet_id:long, contributors:chararray);
cut_tweet = FOREACH tweet GENERATE user_id AS row_key, 'twids' AS column_family, tweet_id AS column_name, '0' AS column_value, CONVERT(created_at) AS timestamp;

STORE cut_tweet INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
