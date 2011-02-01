register /home/jacob/Programming/hbase_bulkloader/build/hbase_bulkloader.jar
register /usr/lib/hbase/lib/jline-0.9.94.jar
register /usr/lib/hbase/lib/guava-r05.jar

-- export PIG_CLASSPATH=/usr/lib/hbase/lib/jline-0.9.94.jar:/usr/lib/hbase/lib/guava-r05.jar:/usr/lib/hbase/lib/commons-lang-2.5.jar:/usr/lib/hbase/hbase.jar:/usr/lib/hbase/hbase-tests.jar:/usr/local/share/pig/pig-0.8.0-core.jar
-- pig -p TABLE=a_rel_b_20110128 -p OUT=/tmp/pagerank/201102/assemble-multigraph-0 assemble_multigraph_hbase.pig

data = LOAD '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('follow:ab follow:ba reply: retweet: mention: ', '-limit 10000000 -loadKey') AS (
        row_key:chararray,
        a_follows_b:int,
        b_follows_a:int,
        replies:bag  { pair:tuple (tweet_id:long, tweet_meta:chararray) },
        retweets:bag { pair:tuple (tweet_id:long, tweet_meta:chararray) },
        mentions:bag { pair:tuple (tweet_id:long, tweet_meta:chararray) }
        );

-- our data only summarizes out relationships between two users
multigraph_out = FOREACH data {
                   ids   = STRSPLIT(row_key, ':', 2);
                   a_f_b = (a_follows_b IS NOT NULL ? 1 : 0);
                   b_f_a = (b_follows_a IS NOT NULL ? 1 : 0);
                   re_o  = COUNT(replies);
                   rt_o  = COUNT(retweets);
                   me_o  = COUNT(mentions);
                   GENERATE
                     FLATTEN(ids) AS (user_a_id:chararray, user_b_id:chararray),
                     a_f_b        AS a_follows_b,
                     b_f_a        AS b_follows_a,
                     re_o         AS re_o,
                     rt_o         AS rt_o,
                     me_o         AS me_o
                   ;
                 };

multigraph_in = FOREACH multigraph_out GENERATE
                  user_b_id   AS user_a_id,
                  user_a_id   AS user_b_id,
                  b_follows_a AS a_follows_b,
                  a_follows_b AS b_follows_a,
                  re_o        AS re_i,
                  rt_o        AS rt_i,
                  me_o        AS me_i
                ;

grouped      = COGROUP multigraph_out BY (user_a_id, user_b_id) OUTER, multigraph_in BY (user_a_id, user_b_id) OUTER;
multigraph   = FOREACH grouped {
                 a_f_b  = (IsEmpty(multigraph_out) ? 0l : SUM(multigraph_out.a_follows_b)) + (IsEmpty(multigraph_in) ? 0l : SUM(multigraph_in.a_follows_b));
                 b_f_a  = (IsEmpty(multigraph_out) ? 0l : SUM(multigraph_out.b_follows_a)) + (IsEmpty(multigraph_in) ? 0l : SUM(multigraph_in.b_follows_a));
                 re_o   = (IsEmpty(multigraph_out) ? 0l : SUM(multigraph_out.re_o));
                 re_i   = (IsEmpty(multigraph_in)  ? 0l : SUM(multigraph_in.re_i));
                 me_o   = (IsEmpty(multigraph_out) ? 0l : SUM(multigraph_out.me_o));
                 me_i   = (IsEmpty(multigraph_in)  ? 0l : SUM(multigraph_in.me_i));
                 rt_o   = (IsEmpty(multigraph_out) ? 0l : SUM(multigraph_out.rt_o));
                 rt_i   = (IsEmpty(multigraph_in)  ? 0l : SUM(multigraph_in.rt_i));
                 GENERATE
                   FLATTEN(group)      AS (user_a_id, user_b_id),
                   (a_f_b > 0 ? 1 : 0) AS a_follows_b,
                   (b_f_a > 0 ? 1 : 0) AS b_follows_a,
                   me_i                AS me_i,
                   me_o                AS me_o,
                   re_i                AS re_i,
                   re_o                AS re_o,
                   rt_i                AS rt_i,
                   rt_o                AS rt_o
                 ;
               };


STORE multigraph INTO '$OUT';
