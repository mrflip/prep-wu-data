-- Params:
--   USAGES, input data
--   USAGE_FREQS, output data

usages = LOAD '$USAGES' AS (rsrc:chararray, token_text:chararray, tweet_id:long, user_id:long, created_at:long);

-- Count (user,token) pairs, number of times user has used a given token ever
user_tokens       = FOREACH usages GENERATE user_id AS user_id, token_text AS token_text;
user_tokens_grpd  = GROUP user_tokens BY (user_id, token_text);
user_token_counts = FOREACH user_tokens_grpd GENERATE FLATTEN(group) AS (user_id, token_text), COUNT(user_tokens) AS num_user_tok_usages;
-- returns (user_id, token_text, num_user_tok_usages)

-- Generate basic counts for a given user
user_usage_bag    = GROUP user_token_counts BY user_id;
user_usage_bag_fg = FOREACH user_usage_bag GENERATE
                      group                                                        AS user_id,
                      FLATTEN(user_token_counts.(token_text, num_user_tok_usages)) AS (token_text, num_user_tok_usages), 
                      COUNT(user_token_counts)                                     AS vocab, 
                      SUM(user_token_counts.num_user_tok_usages)                   AS tot_user_usages
                    ;
-- returns (user_id, token_text, num_user_tok_usages, vocab, tot_user_usages)

-- Generate normalized frequencies from counts
user_usage_freqs = FOREACH user_usage_bag_fg {
                     user_tok_freq    = ((double)num_user_tok_usages / (double)tot_user_usages);
                     user_tok_freq_sq = ((double)num_user_tok_usages / (double)tot_user_usages)*((double)num_user_tok_usages / (double)tot_user_usages);
                     GENERATE
                       token_text          AS token_text,
                       user_id             AS user_id,
                       num_user_tok_usages AS num_user_tok_usages,
                       tot_user_usages     AS tot_user_usages,
                       user_tok_freq       AS user_tok_freq:double,
                       user_tok_freq_sq    AS user_tok_freq_sq:double,
                       vocab               AS vocab
                     ;
                   };
-- returns (token_text, user_id, num_user_tok_usages, tot_user_usages, user_tok_freq, user_tok_freq_sq, vocab)

STORE user_usage_freqs INTO '$USAGE_FREQS';
