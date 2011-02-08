register /home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar
register /usr/lib/hbase/hbase.jar
register /usr/lib/hbase/lib/jline-0.9.94.jar
register /usr/lib/hbase/lib/guava-r05.jar
register /usr/lib/hbase/lib/zookeeper.jar

-- export PIG_CLASSPATH=/usr/lib/hbase/lib/jline-0.9.94.jar:/usr/lib/hbase/lib/guava-r05.jar:/usr/lib/hbase/lib/commons-lang-2.5.jar:/usr/lib/hbase/hbase.jar:/usr/lib/hbase/hbase-tests.jar:/usr/local/share/pig/pig-0.8.0-core.jar
-- pig -p TABLE=a_rel_b_20110128 -p OUT=/tmp/pagerank/201102/assemble-multigraph-0 assemble_multigraph_hbase.pig

data = LOAD 'soc_net_tw_twitter_user' USING com.infochimps.hbase.pig.HBaseStorage('info:screen_name', '-limit 1000 -loadKey');
DUMP data;
