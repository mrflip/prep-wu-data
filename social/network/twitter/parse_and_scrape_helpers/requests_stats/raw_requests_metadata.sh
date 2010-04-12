#!/usr/bin/env bash

# Twitter API requests on and before 200907*:
#   friends_ids             1              0041796745      1                                               anouschka_37    http://twitter.com/friends/ids/0041796745.json  20090708004759  200     OK      [24330946,39677217,19425927,16933337,3818
# Twitter API requests after 200908*:
#   twitter_user_request    25117369        1               http://twitter.com/users/show/25117369.json     20090801012103  200     OK      {"following":false,"

# Twitter API requests in 200911 seem to have -xxxx on rsrc part

# hdp-rm -r /data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_api_v1_requests_metadata ;
# /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar                          \
#     -mapper      "cut -d'	' -f1,2,3,6,7"                                                                   \
#     -reducer     "/usr/bin/uniq"                                                                                 \
#     -input       "s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20090[89]*/*,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/20091*/*,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter/2010*/*" \
#     -output      "/data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_api_v1_requests_metadata"    \
#     -cmdenv LC_ALL=C                                                                                             \
#     -jobconf mapred.reduce.tasks=0 ;

# Twitter search requests on and before 200908* :
#   twitter_search_request  http://search.twitter.com/search.json?q=night&rpp=100&max_id=3279499750 20090813034304  200     OK      {"results":[{"text":"Discussing
# Twitter search requests on and after 200909* :
#   twitter_search_request-http     http    1        {}     http://search.twitter.com/search.json?q=http&rpp=100    20090929232555  200     OK      {"results":[{"profile

hdp-rm -r /data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_search_v1_requests_metadata ;
/usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar                          \
    -mapper      "cut -d'	' -f1,2,3,6,7"                                                                   \
    -reducer     "/usr/bin/uniq"                                                                                 \
    -input       "s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/200909*/*,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/20091*/*,s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/2010*/*" \
    -output      "/data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_search_v1_requests_metadata"    \
    -cmdenv LC_ALL=C                                                                                             \
    -jobconf mapred.reduce.tasks=0 ;

# hdp-rm -r /data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_search_requests_metadata ;
# /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar                          \
#     -mapper      "cut -d'	' -f1,2,3,5,6"                                                                   \
#     -reducer     "/usr/bin/uniq"                                                                                 \
#     -input       "s3n://monkeyshines.infochimps.org/data/ripd/com.tw/com.twitter.search/20/*"                     \
#     -output      "/data/rawd/social/network/twitter/scrape_stats/requests_metadata/raw_search_requests_metadata" \
#     -cmdenv LC_ALL=C                                                                                             \
#     -jobconf mapred.reduce.tasks=0

