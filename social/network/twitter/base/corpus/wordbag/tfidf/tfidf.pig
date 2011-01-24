-- Params:
--   N_USERS,          number of users (documents) in corpus, 'combine input groups' from document_frequencies.pig
--   USAGE_FREQS,      input data
--   USER_TOKEN_GRAPH, output data
--
-- Command:
-- pig -p N_USERS=<get from counters>l -p USAGE_FREQS=/output/of/document_frequencies -p USER_TOKEN_GRAPH=/path/to/output tfidf.pig
--

REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;

user_usage_freqs = LOAD '$USAGE_FREQS' AS (token_text:chararray, user_id:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);
user_freqs       = FOREACH user_usage_freqs GENERATE user_id, token_text, user_tok_freq;
token_usage_bag  = GROUP user_freqs BY token_text;
token_usages     = FOREACH token_usage_bag GENERATE
                     FLATTEN(user_freqs) AS (user_id, token_text, user_tok_freq),
                     COUNT(user_freqs)   AS num_token_users
                   ;

bipartite_graph  = FOREACH token_usages {
                     idf    = org.apache.pig.piggybank.evaluation.math.LOG((double)$N_USERS/(double)num_token_users);
                     tf_idf = (double)user_tok_freq*idf;
                     GENERATE
                       user_id    AS user_id,
                       token_text AS token_text,
                       tf_idf     AS tf_idf
                     ;
                   };

STORE bipartite_graph INTO '$USER_TOKEN_GRAPH';
