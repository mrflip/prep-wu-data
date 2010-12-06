--
-- Just get number of unique users in document collection
--
%default TOKS   '/data/terms/tdidf/word_token'
word_token = LOAD '$TOKS' AS (rsrc:chararray, term:chararray, tweet_id:long, user_id:long, created_at:long);
users      = FOREACH word_token GENERATE user_id;
users_d    = DISTINCT users;
users_g    = GROUP users_d ALL;
users_c    = FOREACH users_g GENERATE COUNT(users_d) AS n_users;
DUMP users_c;
