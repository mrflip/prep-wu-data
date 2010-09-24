%default TABLE 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/influencer_metrics_table'

metrics    = LOAD '$TABLE' AS (uid:int, sn:chararray, crat:long, followers:float, tweet_influx:float, tweet_outflux:float, enthusiasm:float, interesting:float, feedness:float, chattiness:float, sway:float, follow_rate:float, follow_churn:float, mention_trstrank:float, follow_trstrank:float);
metrics_fg = FOREACH metrics GENERATE followers, tweet_influx, tweet_outflux, enthusiasm, interesting, feedness, chattiness, sway, follow_rate, follow_churn, mention_trstrank, follow_trstrank;
metrics_r  = STREAM metrics_fg THROUGH `round_fields.rb --map` AS (followers:float, tweet_influx:float, tweet_outflux:float, enthusiasm:float, interesting:float, feedness:float, chattiness:float, sway:float, follow_rate:float, follow_churn:float, mention_trstrank:float, follow_trstrank:float);

followers_g        = GROUP metrics_r BY followers;
followers_d        = FOREACH followers_g GENERATE group AS followers, COUNT(metrics_r) AS count;

tweet_influx_g     = GROUP metrics_r BY tweet_influx;
tweet_influx_d     = FOREACH tweet_influx_g GENERATE group AS tweet_influx, COUNT(metrics_r) AS count;

tweet_outflux_g    = GROUP metrics_r BY tweet_outflux;
tweet_outflux_d    = FOREACH tweet_outflux_g GENERATE group AS tweet_outflux, COUNT(metrics_r) AS count;

enthusiasm_g       = GROUP metrics_r BY enthusiasm;
enthusiasm_d       = FOREACH enthusiasm_g GENERATE group AS enthusiasm, COUNT(metrics_r) AS count;

interesting_g      = GROUP metrics_r BY interesting;
interesting_d      = FOREACH interesting_g GENERATE group AS interesting, COUNT(metrics_r) AS count;

feedness_g         = GROUP metrics_r BY feedness;
feedness_d         = FOREACH feedness_g GENERATE group AS feedness, COUNT(metrics_r) AS count;

chattiness_g       = GROUP metrics_r BY chattiness;
chattiness_d       = FOREACH chattiness_g GENERATE group AS chattiness, COUNT(metrics_r) AS count;

sway_g             = GROUP metrics_r BY sway;
sway_d             = FOREACH sway_g GENERATE group AS sway, COUNT(metrics_r) AS count;

follow_rate_g      = GROUP metrics_r BY follow_rate;
follow_rate_d      = FOREACH follow_rate_g GENERATE group AS follow_rate, COUNT(metrics_r) AS count;

follow_churn_g     = GROUP metrics_r BY follow_churn;
follow_churn_d     = FOREACH follow_churn_g GENERATE group AS follow_churn, COUNT(metrics_r) AS count;

mention_trstrank_g = GROUP metrics_r BY mention_trstrank;
mention_trstrank_d = FOREACH mention_trstrank_g GENERATE group AS mention_trstrank, COUNT(metrics_r) AS count;

follow_trstrank_g  = GROUP metrics_r BY follow_trstrank;
follow_trstrank_d  = FOREACH follow_trstrank_g GENERATE group AS follow_trstrank, COUNT(metrics_r) AS count;

STORE followers_d        INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/followers'
STORE tweet_influx_d     INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/tweet_influx'
STORE tweet_outflux_d    INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/tweet_outflux'
STORE enthusiasm_d       INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/enthusiasm'
STORE interesting_d      INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/interesting'
STORE feedness_d         INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/feedness'
STORE chattiness_d       INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/chattiness'
STORE sway_d             INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/sway'
STORE follow_rate_d      INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/follow_rate'
STORE follow_churn_d     INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/follow_churn'
STORE mention_trstrank_d INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/mention_trstrank'
STORE follow_trstrank_d  INTO 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/distributions/follow_trstrank'
