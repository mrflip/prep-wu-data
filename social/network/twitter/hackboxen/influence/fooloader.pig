register /home/jacob/Programming/troop/vendor/jars/hbase-0.89.20100924+28-sources.jar;        
register /home/jacob/Programming/troop/vendor/jars/lucene-queries-3.0.3.jar;        
register /home/jacob/Programming/troop/vendor/jars/guava-r05.jar;        
register /home/jacob/Programming/troop/vendor/jars/zookeeper-3.3.1+10.jar;        
register /home/jacob/Programming/troop/vendor/jars/lucene-highlighter-3.0.3.jar;        
register /home/jacob/Programming/troop/vendor/jars/hbase-0.89.20100924+28.jar;        
register /home/jacob/Programming/troop/vendor/jars/lucene-memory-3.0.3.jar;        
register /home/jacob/Programming/troop/vendor/jars/elasticsearch-0.14.2.jar;        
register /home/jacob/Programming/troop/vendor/jars/hbase_bulkloader.jar;        
register /home/jacob/Programming/troop/vendor/jars/log4j-1.2.15.jar;        
register /home/jacob/Programming/troop/vendor/jars/lucene-fast-vector-highlighter-3.0.3.jar;        
register /home/jacob/Programming/troop/vendor/jars/lucene-analyzers-3.0.3.jar;        
register /home/jacob/Programming/troop/vendor/jars/jline-0.9.94.jar;        
register /home/jacob/Programming/troop/vendor/jars/lucene-core-3.0.3.jar;        
register /home/jacob/Programming/troop/vendor/jars/wonderdog.jar;        
register /home/jacob/Programming/troop/vendor/jars/jna-3.2.7.jar;        
register /home/jacob/Programming/troop/vendor/jars/sigar/sigar-1.6.3.jar;        
        
data = LOAD '/mnt/tmp/data/hb/social/network/tw/influence/fixd/data/trstrank_hbase' AS (
        row_key:int,
        screen_name:chararray,
        user_id:int,
        trstrank:float,
        tq:int
        );

STORE data INTO 'soc_net_tw_trstrank' USING com.infochimps.hbase.pig.HBaseStorage(
        'base:screen_name base:user_id base:trstrank base:tq '
        );
