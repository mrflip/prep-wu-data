#!/usr/bin/env bash

script_dir=`dirname $0`
perlgrep=$script_dir/perlgrep.pl

# ~/ics/icsdata/social/network/twitter/parse_and_scrape_helpers/last_seen_state.rb --run --rm     \
#   --map_command="$perlgrep twitter_user"                                                        \
#   "/data/rawd/social/network/twitter/partial_uniq/twitter_user,/data/fixd/tw/out/twitter_user"  \
#   "/data/rawd/social/network/twitter/objects/twitter_user"

# ~/ics/icsdata/social/network/twitter/parse_and_scrape_helpers/last_seen_state.rb --run --rm     \
#   --map_command="$perlgrep twitter_user_profile"                                                        \
#   "/data/rawd/social/network/twitter/partial_uniq/twitter_user_profile,/data/fixd/tw/out/twitter_user_profile"  \
#   "/data/rawd/social/network/twitter/objects/twitter_user_profile"
# 
# ~/ics/icsdata/social/network/twitter/parse_and_scrape_helpers/last_seen_state.rb --run --rm     \
#   --map_command="$perlgrep twitter_user_style"                                                        \
#   "/data/rawd/social/network/twitter/partial_uniq/twitter_user_style,/data/fixd/tw/out/twitter_user_style"  \
#   "/data/rawd/social/network/twitter/objects/twitter_user_style"

~/ics/icsdata/social/network/twitter/parse_and_scrape_helpers/last_seen_state.rb --run --rm     \
  --map_command="$perlgrep twitter_user_partial"                                                        \
  "/data/rawd/social/network/twitter/parsed/\*/\*/part-*,/data/fixd/tw/out/twitter_user_partial"  \
  "/data/rawd/social/network/twitter/objects/twitter_user_partial"

~/ics/icsdata/social/network/twitter/parse_and_scrape_helpers/last_seen_state.rb --run --rm     \
  --map_command="$perlgrep twitter_user_search_id"                                                        \
  "/data/rawd/social/network/twitter/parsed/\*/\*/part-*,/data/fixd/tw/out/twitter_user_search_id"  \
  "/data/rawd/social/network/twitter/objects/twitter_user_search_id"

# /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar \
#     -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner                  \
#     -jobconf     num.key.fields.for.partition="3"                                       \
#     -jobconf     stream.num.map.output.key.fields="3"                                   \
#     -mapper      "perl -ne 'print if \$_ =~ /^twitter_user\\b/'"                        \
#     -reducer     "/usr/bin/uniq"                                                        \
#     -input       "/data/rawd/social/network/twitter/parsed/\*/\*/part-*"                \
#     -output      "/data/rawd/social/network/twitter/objects/twitter_user"               \
#     -cmdenv LC_ALL=C -jobconf mapred.reduce.tasks=200
# 
# /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar \
#     -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner                  \
#     -jobconf     num.key.fields.for.partition="3"                                       \
#     -jobconf     stream.num.map.output.key.fields="3"                                   \
#     -mapper      "perl -ne 'print if \$_ =~ /^twitter_user_profile/'"                    \
#     -reducer     "/usr/bin/uniq"                                                        \
#     -input       "/data/rawd/social/network/twitter/parsed/\*/\*/part-*"                \
#     -output      "/data/rawd/social/network/twitter/objects/twitter_user_profile"       \
#     -cmdenv LC_ALL=C -jobconf mapred.reduce.tasks=200
# 
# /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar \
#     -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner                  \
#     -jobconf     num.key.fields.for.partition="3"                                       \
#     -jobconf     stream.num.map.output.key.fields="3"                                   \
#     -mapper      "perl -ne 'print if \$_ =~ /^twitter_user_style/'"                     \
#     -reducer     "/usr/bin/uniq"                                                        \
#     -input       "/data/rawd/social/network/twitter/parsed/\*/\*/part-*"                \
#     -output      "/data/rawd/social/network/twitter/objects/twitter_user_style"         \
#     -cmdenv LC_ALL=C -jobconf mapred.reduce.tasks=200

# /data/fixd/tw/out
#
# /data/fixd/tw/models/twitter_user_partial                                     507543669        484.0 MB
# /data/fixd/tw/models/twitter_user                                            2067681627          1.9 GB
# /data/fixd/tw/models/twitter_user_profile                                    2914843543          2.7 GB
# /data/fixd/tw/models/twitter_user_style                                      5780222527          5.4 GB
#
# /data/fixd/tw/out/a_favorites_b                                                55582542         53.0 MB
# /data/fixd/tw/out/twitter_user_search_id                                      651677519        621.5 MB
# /data/fixd/tw/out/twitter_user_id                                            2290891310          2.1 GB
# /data/fixd/tw/out/a_replies_b_name                                           5507737374          5.1 GB
# /data/fixd/tw/out/twitter_user_partial                                       8522117554          7.9 GB
# /data/fixd/tw/out/twitter_user                                              24615935155         22.9 GB
# /data/fixd/tw/out/a_follows_b                                               30217117740         28.1 GB
# /data/fixd/tw/out/tweet                                                     47690334777         44.4 GB
# /data/fixd/tw/out/twitter_user_profile                                      52577068037         49.0 GB
# /data/fixd/tw/out/twitter_user_style                                        70030154611         65.2 GB
# /data/fixd/tw/out/search_tweet                                              89605938505         83.5 GB

