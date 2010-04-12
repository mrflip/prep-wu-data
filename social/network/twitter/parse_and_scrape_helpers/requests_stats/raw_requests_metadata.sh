#!/usr/bin/env bash

hdp-rm -r /data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_api_requests_metadata ;
/usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar                          \
    -mapper      "cut -d'	' -f1,2,3,6,7"                                                                   \
    -reducer     "/usr/bin/uniq"                                                                                 \
    -input       "s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/*/*"                            \
    -output      "/data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_api_requests_metadata"    \
    -cmdenv LC_ALL=C                                                                                             \
    -jobconf mapred.reduce.tasks=0 ;

hdp-rm -r /data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_search_requests_metadata ;
/usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar                          \
    -mapper      "cut -d'	' -f1,2,3,6,7"                                                                   \
    -reducer     "/usr/bin/uniq"                                                                                 \
    -input       "s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/*/*"                     \
    -output      "/data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_search_requests_metadata" \
    -cmdenv LC_ALL=C                                                                                             \
    -jobconf mapred.reduce.tasks=0
