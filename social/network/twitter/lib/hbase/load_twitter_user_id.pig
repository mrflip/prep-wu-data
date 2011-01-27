--
-- Load Twitter User ID using pig and HBase TableOutputFormat
--
register '/home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/twitter_user_id/part-00000'
%default TABLE 'soc_net_tw_twitter_user'
%default CF    'info'

data       = LOAD '$DATA' AS (rsrc:chararray, uid:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:int, friends_count:int, statuses_count:int, favourites_count:int, created_at:long, sid:long, is_full:int, health:chararray);
cut_fields = FOREACH data GENERATE uid AS key, uid AS user_id, scraped_at, screen_name, protected, followers_count, friends_count, statuses_count, favourites_count, created_at, sid,is_full, health;
STORE cut_fields INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:user_id $CF:scraped_at $CF:screen_name $CF:protected $CF:followers_count $CF:friends_count $CF:statuses_count $CF:favourites_count $CF:created_at $CF:sid $CF:is_full $CF:health', '-timestamp_field 2');
