--
-- Oops, forgot to sort the results in the previous step
--
data = LOAD '$DIST' AS (user_id:int, num_tweets:int);
srtd = ORDER data BY num_tweets DESC;

STORE srtd INTO '$HDFS/$OUT';
