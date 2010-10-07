%default TWPROF '/tmp/new_style/twitter_user_profile,s3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/20100806/twitter_user_profile'

twitter_user_profile = LOAD '$TWPROF' AS (rsrc:chararray, uid:long, scrat:long, sn:chararray, name:chararray, url:chararray, loc:chararray, descr:chararray, tz:chararray, utc:chararray, lang:chararray, geo_en:int, verified:int, contributors_enabled:int);
twitter_user_profile_d = DISTINCT twitter_user_profile;

rmf /tmp/fixd/twitter_user_profile
STORE twitter_user_profile_d INTO '/tmp/fixd/twitter_user_profile';
