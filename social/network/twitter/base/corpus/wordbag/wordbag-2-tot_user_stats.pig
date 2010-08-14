-- map input records to first mr job    = tot usages
-- reduce input groups in second mr job = tot users

-- PIG_OPTS='-Dmapred.min.split.size=536870912 -Dio.sort.mb=600' pig -p WORDBAG_ROOT=/tmp/wordbag ~/ics/icsdata/social/network/twitter/base/corpus/wordbag/global_token_stats.pig

%default WORDBAG_ROOT            '/data/sn/tw/fixd/wordbag';

REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;
usage_user_stats = LOAD '$WORDBAG_ROOT/usage_user_stats' AS (tok:chararray, uid:long, num_user_tok_usages:long, tot_user_usages:long, user_tok_freq:double, user_tok_freq_sq:double, vocab:long);

-- get num users and tot usages. The tot_user_usages is denormalized across all
-- of each user's rows, so 
tot_user_stats_0  = FOREACH  usage_user_stats GENERATE uid, tot_user_usages;
tot_user_stats_uq = DISTINCT tot_user_stats_0   PARALLEL 5;
tot_user_stats_g  = GROUP tot_user_stats_uq ALL PARALLEL 1;
tot_user_stats    = FOREACH tot_user_stats_g {
  -- yes, I KNOW these can be obtained from the counters, try automating that simply and then we'll talk
  n_users      = (double)COUNT(tot_user_stats_uq);
  sqrt_n_users = org.apache.pig.piggybank.evaluation.math.SQRT(n_users);
  tot_usages   = (double)SUM(tot_user_stats_uq.tot_user_usages);
  GENERATE
    n_users                 AS n_users,
    (sqrt_n_users - 1.0)    AS sqrt_n_users_m1,
    tot_usages              AS tot_usages
    ;
  };

rmf                        $WORDBAG_ROOT/tot_user_stats
STORE tot_user_stats INTO '$WORDBAG_ROOT/tot_user_stats';
tot_user_stats     = LOAD '$WORDBAG_ROOT/tot_user_stats' AS (n_users:double, sqrt_n_users_m1:double, tot_usages:double);

DUMP tot_user_stats;
