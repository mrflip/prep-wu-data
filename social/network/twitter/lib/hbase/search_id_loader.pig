--
-- Load Twitter User by Search ID using pig and HBase TableOutputFormat
--
register '/home/travis/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/twitter_user_id'
%default TABLE 'soc_net_tw_twitter_user'
%default CF    'search_id'

data       = LOAD '$DATA' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, protected:int, followers_count:int, friends_count:int, statuses_count:int, favourites_count:int, created_at:long, sid:long, is_full:int, health:chararray);
record     = FILTER data BY screen_name is not null AND sid is not null;
cut_record = FOREACH record GENERATE sid AS key, sid AS search_id, screen_name, user_id;
STORE cut_record INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:search_id $CF:screen_name $CF:user_id');
