#!/usr/bin/env bash

script_dir=$(readlink -f `dirname $0`)
perlgrep=$script_dir/perlgrep.pl

# for object in twitter_user twitter_user_profile twitter_user_style twitter_user_partial ; do
#   ~/ics/icsdata/social/network/twitter/parse_and_scrape_helpers/last_seen_state.rb --run --rm     \
#     --map_command="$perlgrep $object"                                                        \
#     "/data/rawd/social/network/twitter/partial_uniq/$object,/data/fixd/tw/out/$object"  \
#     "/data/rawd/social/network/twitter/objects/$object"
# done

# for object in a_favorites_b tweet
#   hdp-rm -r /data/rawd/social/network/twitter/objects/$object
#   /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar       \
#     -D           mapred.reduce.tasks=200                                                       \
#     -D           stream.num.map.output.key.fields="2"                                          \
#     -mapper      "$perlgrep $object"                                                             \
#     -reducer     "/usr/bin/uniq"                                                               \
#     -input       "/data/fixd/tw/out/$object,/data/rawd/social/network/twitter/parsed/api/*/part-*,/data/rawd/social/network/twitter/parsed/stream/*/part-*" \
#     -output      "/data/rawd/social/network/twitter/objects/$object"                             \
#     -cmdenv       LC_ALL=C
# done

# search_tweet twitter_user_search_id a_replies_b_name
for object in twitter_user_search_id a_replies_b_name ; do
  hdp-rm -r /data/rawd/social/network/twitter/objects/$object
  /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar             \
    -D           mapred.reduce.tasks=57                                                               \
    -D           stream.num.map.output.key.fields="2"                                                 \
    -mapper      "$perlgrep $object"                                                                  \
    -reducer     "/usr/bin/uniq"                                                                      \
    -input       "/data/fixd/tw/out/$object,/data/rawd/social/network/twitter/parsed/search/*/part-*" \
    -output      "/data/rawd/social/network/twitter/objects/$object"                                  \
    -cmdenv       LC_ALL=C
done

# delete_tweet
for object in delete_tweet ; do
  hdp-rm -r /data/rawd/social/network/twitter/objects/$object
  /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar             \
    -D           mapred.reduce.tasks=57                                                               \
    -D           stream.num.map.output.key.fields="2"                                                 \
    -mapper      "$perlgrep $object"                                                                  \
    -reducer     "/usr/bin/uniq"                                                                      \
    -input       "/data/fixd/tw/parsed2/com.twitter.stream/part-*,/data/rawd/social/network/twitter/parsed/stream/*/part-*" \
    -output      "/data/rawd/social/network/twitter/objects/$object"                                  \
    -cmdenv       LC_ALL=C
done

# for token in a_atsigns_b a_replies_b a_retweets_b hashtag tweet_url smiley ; do
#   hdp-rm -r /data/rawd/social/network/twitter/objects/$token
#   /usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar \
#     -D           mapred.reduce.tasks=0                                                    \
#     -mapper      "$perlgrep $token"                                                       \
#     -reducer     ""                                                                       \
#     -input       "/data/rawd/social/network/twitter/parsed/raw_tweet_tokens"              \
#     -output      "/data/rawd/social/network/twitter/objects/$token"                       \
#     -cmdenv       LC_ALL=C
# done



# /data/fixd/tw/out
#
# /data/fixd/tw/models/twitter_user_partial                                     507543669        484.0 MB
# /data/fixd/tw/models/twitter_user                                            2067681627          1.9 GB
# /data/fixd/tw/models/twitter_user_profile                                    2914843543          2.7 GB
# /data/fixd/tw/models/twitter_user_style                                      5780222527          5.4 GB
#
# /data/fixd/tw/out/a_favorites_b                                                55582542         53.0 MB
# /data/fixd/tw/out/a_replies_b_name                                           5507737374          5.1 GB
# /data/fixd/tw/out/a_follows_b                                               30217117740         28.1 GB
# /data/fixd/tw/out/tweet                                                     47690334777         44.4 GB
# /data/fixd/tw/out/search_tweet                                              89605938505         83.5 GB
#
# /data/fixd/tw/out/twitter_user_search_id                                      651677519        621.5 MB
# /data/fixd/tw/out/twitter_user_id                                            2290891310          2.1 GB
# /data/fixd/tw/out/twitter_user_partial                                       8522117554          7.9 GB
# /data/fixd/tw/out/twitter_user                                              24615935155         22.9 GB
# /data/fixd/tw/out/twitter_user_profile                                      52577068037         49.0 GB
# /data/fixd/tw/out/twitter_user_style                                        70030154611         65.2 GB

