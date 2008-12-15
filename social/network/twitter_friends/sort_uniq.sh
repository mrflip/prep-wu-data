#!/usr/bin/env bash
input_id=$1
output_id=$2
hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-*-streaming.jar		\
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 		\
    -jobconf    map.output.key.field.separator='\t'				\
    -jobconf    num.key.fields.for.partition=1 					\
    -jobconf stream.map.output.field.separator='\t'				\
    -jobconf stream.num.map.output.key.fields=2					\
    -mapper	/bin/cat							\
    -reducer	/home/flip/ics/pool/social/network/twitter_friends/hadoop_uniq_without_timestamp.rb \
    -file    hadoop_utils.rb							\
    -input  "out/parsed-$input_id"						\
    -output "out/sorted-$output_id"



  # -D mapred.map.tasks=3							\
  # -D mapred.reduce.tasks=3							\
  # -jobconf stream.num.map.output.key.fields=1					\
  
  # -jobconf stream.num.map.output.key.fields=1					\
  # -jobconf mapred.text.key.partitioner.options=-k1,2				\
  # -jobconf stream.map.output.field.separator='-'				\
  # -jobconf        map.output.key.field.separator='-'				\
  
  
# -mapper 	org.apache.hadoop.mapred.lib.IdentityMapper			\
# -reducer	org.apache.hadoop.mapred.lib.IdentityReducer			\
# -partitioner	org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner		\
# hadoop jar ~/hadoop/hadoop-*-examples.jar sort				\
#    -m 3 -r 3									\
#    -inFormat org.apache.hadoop.mapred.TextInputFormat				\
#    -outFormat org.apache.hadoop.mapred.TextOutputFormat			\
#   out/parsed out/parsed-sort 
  
