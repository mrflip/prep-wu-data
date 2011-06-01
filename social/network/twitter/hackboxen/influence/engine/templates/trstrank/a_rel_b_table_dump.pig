register /home/travis/dev/troop/vendor/jars/infochimps-piggybank-1.0-SNAPSHOT.jar;
register /home/travis/dev/troop/vendor/jars/jline-0.9.94.jar;
register /home/travis/dev/troop/vendor/jars/guava-r06.jar;
register /home/travis/dev/troop/vendor/jars/hbase-0.90.1-cdh3u0.jar;
register /home/travis/dev/troop/vendor/jars/zookeeper-3.3.1+10.jar;

data = LOAD 'soc_net_tw_a_rel_b' USING com.infochimps.hadoop.pig.hbase.StaticFamilyStorage('follow:ab follow:ba reply: retweet: mention: ', '-loadKey -config /etc/hbase/conf/hbase-site.xml') AS (
        row_key:chararray,
        a_follows_b:int,
        b_follows_a:int,
        replies:bag  { pair:tuple (tweet_id:long, tweet_meta:chararray) },
        retweets:bag { pair:tuple (tweet_id:long, tweet_meta:chararray) },
        mentions:bag { pair:tuple (tweet_id:long, tweet_meta:chararray) }
        );
STORE data INTO '/tmp/a_rel_b';
