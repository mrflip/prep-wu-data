#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers
input_id=$1
output_id=$2
hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-*-streaming.jar			\
    -mapper  /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
    -reducer /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_reduce.rb	\
    -input   /user/flip/rawd/social/network/twitter_friends-$input_id/'*'	 	\
    -output  "out/parsed-$output_id"									\
    -file    hadoop_utils.rb								\
    -file    twitter_autourl.rb

#  -jobconf mapred.reduce.tasks=4
    # -jobconf map.output.key.field.separator='\t'					\
    # -jobconf num.key.fields.for.partition=1 						\
    # -jobconf stream.map.output.field.separator='\t'					\
    # -jobconf stream.num.map.output.key.fields=2						\
