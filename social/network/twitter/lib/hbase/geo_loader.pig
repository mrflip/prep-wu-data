--
-- Load Twitter Geo data using pig and HBase TableOutputFormat
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/geo'
%default TABLE 'soc_net_tw_geo'
%default CF    'base'

data       = LOAD '$DATA' AS (rsrc:chararray, twid:long, created_at:long, user_id:long, screen_name:chararray, lng:float, lat:float, place_id:chararray, place_fn:chararray, user_location:chararray, user_tz:chararray);
cut_record = FOREACH data GENERATE twid AS key, twid AS tweet_id, created_at, user_id, screen_name, lng, lat, place_id, place_fn, user_location, user_tz;   
STORE cut_record INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:tweet_id $CF:created_at $CF:user_id $CF:screen_name $CF:lng $CF:lat $CF:place_id $CF:place_fn $CF:user_location $CF:user_tz');
