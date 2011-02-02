--
-- Load Tweet Url using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/tweet_url'
%default TABLE 'soc_net_tw_tweet_url'
%default CF    'base'

data       = LOAD '$DATA' AS (rsrc:chararray, url:chararray, tweet_id:long, user_id:long, scraped_at:long);
cut_record = FOREACH data GENERATE url AS key, url AS tweet_url, tweet_id, user_id, scraped_at;
STORE cut_record INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:tweet_url $CF:tweet_id $CF:user_id $CF:scraped_at');
