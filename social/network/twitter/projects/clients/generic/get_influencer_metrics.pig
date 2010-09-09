--
-- Read in a set of uids and join with influencer metrics
--

%default METRICS 's3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/graph/influencer_metrics'
%default UIDS    '/tmp/bigsheets_demo/lady_gaga_uids'        

metrics    = LOAD '$METRICS' AS (rsrc:chararray, sn:chararray, uid:long, crat:long, followers:float, fo_o:float, fo_i:float, at_o:float, at_i:float, re_o:float, re_i:float, rt_o:float, rt_i:float, tw_o:float, tw_i:float, ms_tw_o:float, hsh_o:float, sm_o:float, url_o:float, at_tr:float, fo_tr:float);
users      = LOAD '$UIDS'    AS (uid:long);
metrics_j  = JOIN metrics BY uid, users BY uid USING 'replicated';
metrics_fg = FOREACH metrics_j {
               days_since   = 20100908l - (metrics::crat / 1000000l);
               feedness     = metrics::url_o / metrics::tw_o;
               interesting  = (5.0f*metrics::at_i) / metrics::tw_o;
               sway         = (5.0f*metrics::rt_i) / metrics::tw_o;
               chattiness   = metrics::at_o / metrics::tw_o;
               enthusiasm   = metrics::rt_o / metrics::tw_o;
               influx       = metrics::tw_i / (float)days_since;
               outflux      = metrics::tw_o / (float)days_since;
               follow_churn = metrics::fo_o / metrics::followers;
               follow_rate  = metrics::followers / (float)days_since;
               GENERATE
                 users::uid         AS user_id,
                 metrics::sn        AS screen_name,
                 metrics::crat      AS created_at,
                 metrics::followers AS followers,
                 influx             AS tweet_influx,
                 outflux            AS tweet_outflux,
                 enthusiasm         AS enthusiasm,
                 interesting        AS interesting,
                 feedness           AS feedness,
                 chattiness         AS chattiness,
                 sway               AS sway,
                 follow_rate        AS follow_rate,
                 follow_churn       AS follow_churn,
                 metrics::at_tr     AS mention_trstrank,
                 metrics::fo_tr     AS follower_trstrank
               ;
             };

STORE metrics_fg INTO '/tmp/bigsheets_demo/lady_gaga_metrics';
