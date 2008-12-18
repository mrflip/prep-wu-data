#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers
input_id=$1
output_id=$2
hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-*-streaming.jar			\
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 			\
    -jobconf    map.output.key.field.separator='\t'					\
    -jobconf    num.key.fields.for.partition=1 						\
    -jobconf 	stream.map.output.field.separator='\t'					\
    -jobconf 	stream.num.map.output.key.fields=2					\
    -mapper  	/home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
    -reducer	/home/flip/ics/pool/social/network/twitter_friends/hadoop_uniq_without_timestamp.rb \
    -input      rawd/keyed/_20081126'/*',rawd/keyed/_20081127'/*',rawd/keyed/_20081128'/*',rawd/keyed/_20081129'/*',rawd/keyed/_20081130'/*',rawd/keyed/_20081201'/*',rawd/keyed/_20081202'/*',rawd/keyed/_20081203'/*',rawd/keyed/_20081204'/*',rawd/keyed/_20081205'/*',rawd/keyed/_20081206'/*',rawd/keyed/_20081207'/*',rawd/keyed/_20081208'/*',rawd/keyed/_20081209'/*',rawd/keyed/_20081210'/*',rawd/keyed/_20081211'/*',rawd/keyed/_20081212'/*',rawd/keyed/_20081213'/*',rawd/keyed/_20081215'/*',rawd/keyed/_20081216'/*',rawd/keyed/_20081217'/*' \
    -output  	out/"parsed-$output_id"							\
    -file    	hadoop_utils.rb								\
    -file    	twitter_flat_model.rb							\
    -file    	twitter_autourl.rb

# 	rawd/keyed/_20081126'/*',rawd/keyed/_20081127'/*',rawd/keyed/_20081128'/*',rawd/keyed/_20081129'/*',rawd/keyed/_20081130'/*',rawd/keyed/_20081201'/*',rawd/keyed/_20081202'/*',rawd/keyed/_20081203'/*',rawd/keyed/_20081204'/*',rawd/keyed/_20081205'/*',rawd/keyed/_20081206'/*',rawd/keyed/_20081207'/*',rawd/keyed/_20081208'/*',rawd/keyed/_20081209'/*',rawd/keyed/_20081210'/*',rawd/keyed/_20081211'/*',rawd/keyed/_20081212'/*',rawd/keyed/_20081212'/*',rawd/keyed/_20081213'/*' \


