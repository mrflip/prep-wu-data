register /home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar
register /home/jacob/Programming/wonderdog/build/wonderdog.jar
register /usr/lib/hbase/lib/jline-0.9.94.jar
register /usr/lib/hbase/lib/guava-r05.jar
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

%default ES_INDEX    'tweet-201101' -- hmmm
%default ES_OBJ      'tweet'        
%default TWUID_TABLE 'soc_net_tw_twitter_user'
        
-- export PIG_CLASSPATH=/usr/lib/hbase/lib/jline-0.9.94.jar:/usr/lib/hbase/lib/guava-r05.jar:/usr/lib/hbase/lib/commons-lang-2.5.jar:/usr/lib/hbase/hbase.jar:/usr/lib/hbase/hbase-tests.jar:/usr/local/share/pig/pig-0.8.0-core.jar
-- pig -p TABLE=a_rel_b_20110128 -p OUT=/tmp/pagerank/201102/assemble-multigraph-0 assemble_multigraph_hbase.pig
data       = LOAD '$TWUID_TABLE' USING com.infochimps.hbase.pig.HBaseStorage('info:screen_name', '-loadKey') AS (user_id:int, screen_name:chararray);
tweet_noid = LOAD '$TWT' AS (rsrc:chararray,tweet_id:long,created_at:long,user_id:long,screen_name:chararray,search_id:long,in_reply_to_user_id:long,in_reply_to_screen_name:chararray,in_reply_to_search_id:long,in_reply_to_status_id:long,text:chararray,source:chararray,lang:chararray,lat:float,lng:float,retweeted_count:int,rt_of_user_id:long,rt_of_screen_name:chararray,rt_of_tweet_id:long,contributors:chararray);

first_pass = JOIN tweet_noid BY screen_name, data BY screen_name USING 'replicated';
fixed_ids  = FOREACH joined GENERATE
               (data::uid IS NULL ? 'tweet-noid' : 'tweet') AS rsrc,
               tweet_noid::tweet_id                AS tweet_id,
               tweet_noid::created_at              AS created_at,
               data::user_id                       AS user_id,
               tweet_noid::screen_name             AS screen_name,
               tweet_noid::search_id               AS search_id,
               tweet_noid::in_reply_to_user_id     AS in_reply_to_user_id,
               tweet_noid::in_reply_to_screen_name AS in_reply_to_screen_name,
               tweet_noid::in_reply_to_search_id   AS in_reply_to_search_id,
               tweet_noid::text                    AS text,
               tweet_noid::source                  AS source,
               tweet_noid::lang                    AS lang,
               tweet_noid::lat                     AS lat,
               tweet_noid::lng                     AS lng,
               tweet_noid::retweeted_count         AS retweeted_count,
               tweet_noid::rt_of_user_id           AS rt_of_user_id,
               tweet_noid::rt_of_screen_name       AS rt_of_screen_name,
               tweet_noid::rt_of_tweet_id          AS rt_of_tweet_id,
               tweet_noid:::contributors           AS contributors        
             ;

SPLIT fixed_ids INTO noids IF rsrc == 'tweet-noid', rectified IF rsrc == 'tweet';

not_replies = FILTER rectified BY in_reply_to_sn IS NULL;
STORE not_replies INTO 'es://$ES_INDEX/$ES_OBJ' USING com.infochimps.elasticsearch.pig.ElasticSearchIndex('1', '4096');
-- store the not_replies into elasticsearch

replies     = FILTER rectified BY in_reply_to_sn IS NOT NULL;
joined      = JOIN replies BY in_reply_to_sn, data BY screen_name USING 'replicated';
rectified   = FOREACH joined GENERATE
                replies::rsrc                    AS rsrc,
                replies::tweet_id                AS tweet_id,
                replies::created_at              AS created_at,
                replies::user_id                 AS user_id,
                replies::screen_name             AS screen_name,
                replies::search_id               AS search_id,
                data::user_id                    AS in_reply_to_user_id,
                replies::in_reply_to_screen_name AS in_reply_to_screen_name,
                replies::in_reply_to_search_id   AS in_reply_to_search_id,
                replies::text                    AS text,
                replies::source                  AS source,
                replies::lang                    AS lang,
                replies::lat                     AS lat,
                replies::lng                     AS lng,
                replies::retweeted_count         AS retweeted_count,
                replies::rt_of_user_id           AS rt_of_user_id,
                replies::rt_of_screen_name       AS rt_of_screen_name,
                replies::rt_of_tweet_id          AS rt_of_tweet_id,
                replies:::contributors           AS contributors        
              ;

SPLIT rectified INTO no_reply_id IF in_reply_to_user_id IS NULL, with_reply_id IF in_reply_to_user_id IS NOT NULL;
-- store with_reply_id into elasticsearch
STORE with_reply_id INTO 'es://$ES_INDEX/$ES_OBJ' USING com.infochimps.elasticsearch.pig.ElasticSearchIndex('1', '4096');
