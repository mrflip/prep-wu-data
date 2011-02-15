register /home/travis/dev/wonderdog/build/wonderdog.jar
register /usr/local/share/elasticsearch/lib/elasticsearch-0.14.2.jar
register /usr/local/share/elasticsearch/lib/jline-0.9.94.jar
register /usr/local/share/elasticsearch/lib/jna-3.2.7.jar
register /usr/local/share/elasticsearch/lib/log4j-1.2.15.jar
register /usr/local/share/elasticsearch/lib/lucene-analyzers-3.0.3.jar
register /usr/local/share/elasticsearch/lib/lucene-core-3.0.3.jar
register /usr/local/share/elasticsearch/lib/lucene-fast-vector-highlighter-3.0.3.jar
register /usr/local/share/elasticsearch/lib/lucene-highlighter-3.0.3.jar
register /usr/local/share/elasticsearch/lib/lucene-memory-3.0.3.jar
register /usr/local/share/elasticsearch/lib/lucene-queries-3.0.3.jar        

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/twitter_user_profile'
%default INDEX 'soc_net_tw_twitter_user'
%default OBJ   'profile'        

data     = LOAD '$DATA' AS (rsrc:chararray, user_id:long, scraped_at:long, screen_name:chararray, name:chararray, url:chararray, location:chararray, description:chararray, time_zone:chararray, utc_offset:chararray, lang:chararray, geo_enabled:chararray, verified:chararray, contributors_enabled:chararray);
cut_data = FOREACH data GENERATE user_id, scraped_at, screen_name, name, url, location, description, time_zone, utc_offset, lang, geo_enabled, verified, contributors_enabled;
STORE cut_data INTO 'es://$INDEX/$OBJ' USING com.infochimps.elasticsearch.pig.ElasticSearchIndex('0', '500');
