--
-- Load Twitter User by Screen Name(lowercase) using pig and HBase TableOutputFormat
-- 
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/twitter_user_id'
%default TABLE 'soc_net_tw_twitter_user'
%default CF    'screen_name'

data       = LOAD '$DATA' AS (rsrc:chararray, user_id:long, scraped_at:long, sn:chararray, protected:int, followers_count:int, friends_count:int, statuses_count:int, favourites_count:int, created_at:long, sid:long, is_full:int, health:chararray);
record     = FILTER data BY sn is not null;
cut_record = FOREACH record GENERATE LOWER(sn) AS key, sn AS screen_name, sid, user_id;
STORE cut_record INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:screen_name $CF:sid $CF:user_id');
