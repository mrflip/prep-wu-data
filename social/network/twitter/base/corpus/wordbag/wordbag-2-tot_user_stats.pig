-- Params:
--   USAGE_FREQS,  input data
--   USAGE_TOTALS, output data

-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=640' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/global_token_stats.pig

user_usage_freqs = LOAD '$USAGE_FREQS' AS (token_text:chararray, user_id:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);

-- Generate total tokens usages and number of unique users
global_user_usages    = FOREACH  user_usage_freqs GENERATE user_id, tot_user_usages;
global_user_usages_uq = DISTINCT global_user_usages;
global_user_usages_g  = GROUP global_user_usages_uq ALL;
totals                = FOREACH global_user_usages_g {
                          n_users      = (double)COUNT(global_user_usages_uq);
                          sqrt_n_users = org.apache.pig.piggybank.evaluation.math.SQRT(n_users);
                          tot_usages   = (double)SUM(tot_user_stats_uq.tot_user_usages);
                          GENERATE
                            n_users              AS n_users,                 -- unique users
                            (sqrt_n_users - 1.0) AS sqrt_n_users_minus_one,
                            tot_usages           AS tot_usages               -- total usages count
                          ;
                        };
-- returns a single record (n_users, sqrt_n_users_minus_one, tot_usages)

STORE totals INTO '$USAGE_TOTALS';
