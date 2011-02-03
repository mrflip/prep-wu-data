register build/wonderdog.jar
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

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/stock_token'
%default INDEX 'token'
%default OBJ   'stock_token'        

data     = LOAD '$DATA' AS (rsrc:chararray, text:chararray, tweet_id:long, user_id:long, created_at:long);
cut_data = FOREACH data GENERATE text, tweet_id, user_id, created_at; 
STORE cut_data INTO 'es://$INDEX/$OBJ' USING com.infochimps.elasticsearch.pig.ElasticSearchIndex('1', '4096');
