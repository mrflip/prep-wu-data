--
-- Load Twitter User Profile using pig and HBase TableOutputFormat
-- timestamp needs to be formatted to Unix Epoch Time to load into Hbase
--
register '/home/travis/dev/HbaseBulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';
register '/home/travis/dev/HbaseBulkloader/lib/joda-time-1.6.2.jar';

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/twitter_user_profile'
%default TABLE 'soc_net_tw_twitter_user'
%default CF    'profile'

DEFINE CONVERT com.infochimps.hadoop.pig.datetime.StringFormatToUnix();

data     = LOAD '$DATA' AS (rsrc:chararray, uid:long, scraped_at:long, screen_name:chararray, name:chararray, url:chararray, location:chararray, description:chararray, time_zone:chararray, utc_offset:chararray, lang:chararray, geo_enabled:chararray, verified:chararray, contributors_enabled:chararray);
cut_data = FOREACH data GENERATE uid AS key, uid AS user_id, CONVERT(scraped_at), screen_name, name, url, location, description, time_zone, utc_offset, lang, geo_enabled, verified, contributors_enabled;
STORE cut_data INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$CF:user_id $CF:scraped_at $CF:screen_name $CF:name $CF:url $CF:location $CF:description $CF:time_zone $CF:utc_offset $CF:lang $CF:geo_enabled $CF:verified $CF:contributors_enabled', '-timestamp_field 2');





