--
-- Store tweets into hbase so we can test how well we can query
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/home/jacob/Programming/hbase_bulkloader/lib/joda-time-1.6.2.jar';
register '/usr/lib/hbase/hbase.jar';
register '/usr/lib/hbase/lib/zookeeper.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default TOKEN '/tmp/streamed/token'
%default TABLE 'soc_net_tw_token'

DEFINE CONVERT com.infochimps.hadoop.pig.datetime.StringFormatToUnix();

tokens     = LOAD '$TOKEN' AS (rsrc:chararray, text:chararray, tweet_id:long, user_id:int, created_at:chararray, moreinfo:chararray);
cut_tokens = FOREACH tokens GENERATE rsrc AS rsrc, user_id AS user_id, tweet_id AS tweet_id, CONVERT(created_at) AS timestamp;
hbase_form = FOREACH cut_tokens {
               row_key  = user_id;
               col_fam  = (rsrc=='tweet_url' ? 'url' : rsrc);
               col_name = tweet_id;
               col_val  = '0';
               GENERATE row_key, col_fam, col_name, col_val;
             };

STORE hbase_form INTO '$TABLE' USING com.infochimps.hbase.pig.DynamicFamilyStorage();
