%default TWT 's3n://infochimps-data/data/soc/politics/project/twitter_mentions/filtered_tweets_all'

poly_tweets = LOAD '$TWT' AS (poly_name:chararray, key:chararray, rsrc:chararray, twid:chararray, crat:long); --not loading other fields
poly_cut    = FOREACH poly_tweets GENERATE poly_name, crat / 1000000 AS day;
poly_grp    = GROUP poly_cut BY (poly_name, day);
poly_counts = FOREACH poly_grp GENERATE FLATTEN(group) AS (poly_name, day), COUNT(poly_cut) AS num_mentions;

STORE poly_counts INTO '/tmp/politician_mentions';
