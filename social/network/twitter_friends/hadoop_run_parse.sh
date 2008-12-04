#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers

hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-*-streaming.jar		\
  -mapper  /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
  -reducer /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_reduce.rb	\
  -input   /user/flip/rawd/social/network/twitter_friends-20081203/'*'	 	\
  -output  "$1"									\
  -file    hadoop_utils.rb								\
  -file    twitter_autourl.rb

#  -jobconf mapred.reduce.tasks=4
