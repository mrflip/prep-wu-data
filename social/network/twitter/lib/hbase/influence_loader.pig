--
-- Load Influencer Metrics using pig and HBase TableOutputFormat
--
register '/home/travis/dev/hbase_bulkloader/build/hbase_bulkloader.jar';
register '/usr/lib/hbase/lib/jline-0.9.94.jar';
register '/usr/lib/hbase/lib/guava-r05.jar';

%default TABLE 'soc_net_tw_influencer_metrics'

data       = LOAD '$DATA' AS (uid:long, screen_name:chararray, created_at:long, followers:float, tweet_influx:float, tweet_outflux:float, enthusiasm:float, interesting:float, feedness:float, chattiness:float, sway:float, follow_rate:float, follow_churn:float, mention_trstrank:float, follower_trstrank:float);
cut_fields = FOREACH data GENERATE uid AS key, uid AS user_id, screen_name, created_at, followers, influx, outflux, enthusiasm, interesting, feedness, chattiness, sway, follow_rate, follow_churn, at_trstrank, fo_trstrank;
STORE cut_fields INTO '$TABLE' USING com.infochimps.hbase.pig.HBaseStorage('$TODAY:user_id $TODAY:screen_name $TODAY:created_at $TODAY:followers $TODAY:influx $TODAY:outflux $TODAY:enthusiasm $TODAY:interesting $TODAY:feedness $TODAY:chattiness $TODAY:sway $TODAY:follow_rate $TODAY:follow_churn $TODAY:at_trstrank $TODAY:fo_trstrank');

