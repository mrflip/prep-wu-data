#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers

hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-0.19.0-streaming.jar		\
  -mapper  /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
  -reducer /home/flip/ics/pool/social/network/twitter_friends/sort_uniq.sh		\
  -input                  rawd/social/network/twitter_friends/'*'			\
  -output  out/parsed									\
  -file    hadoop_utils.rb								\
  -file    twitter_autourl.rb

#  -jobconf mapred.reduce.tasks=4
