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

%default DATA  's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/current/hashtag'
%default INDEX 'dbpedia'
%default OBJ   'abstracts'        

data = LOAD '$DATA' AS (title:chararray, text:chararray); cut_data = FOREACH
data GENERATE title, abstract; STORE cut_data INTO 'es://$INDEX/$OBJ' USING
com.infochimps.elasticsearch.pig.ElasticSearchIndex('1', '4096');
