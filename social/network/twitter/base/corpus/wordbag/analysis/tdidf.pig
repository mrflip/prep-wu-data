REGISTER /usr/lib/pig/contrib/piggybank/java/piggybank.jar;

%default N_USERS 62399l
        
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
