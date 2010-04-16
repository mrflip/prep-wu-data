B1;2c#!/usr/bin/env bash

script_dir=$(readlink -f `dirname $0`)

hdp-rm -r /data/rawd/social/network/twitter/pagerank/a_replies_b_pagerank/pagerank_only
/usr/lib/hadoop/bin/hadoop jar /usr/lib/hadoop/contrib/streaming/hadoop-*-streaming.jar       \
  -D           mapred.reduce.tasks=200                                                       \
  -D           stream.num.map.output.key.fields="2"                                          \
  -mapper      "/usr/bin/cut -f1,2"                                                      \
  -reducer     "/usr/bin/uniq"                                                               \
  -input       "/data/rawd/social/network/twitter/pagerank/a_replies_b_pagerank/pagerank_graph_010" \
  -output      "/data/rawd/social/network/twitter/pagerank/a_replies_b_pagerank/pagerank_only"                             \
  -cmdenv       LC_ALL=C
