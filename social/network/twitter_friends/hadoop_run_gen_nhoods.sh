#!/usr/bin/env bash

# Where is the latest parsed build?
input_id=${1-`datename`}
output_id=${2-`datename`}

input_file=out/sorted-${input_id}
output_file=out/"neighborhoods-$output_id"

#
# Clear the way
#
# hadoop dfs -rmr $listing_file
hdp-rm -r $output_file

#
# Expand into rows by object
#
hadoop jar $HOME/hadoop/h/contrib/streaming/hadoop-*-streaming.jar			\
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 			\
    -jobconf    map.output.key.field.separator='\t'					\
    -jobconf    num.key.fields.for.partition=1 						\
    -jobconf 	stream.map.output.field.separator='\t'					\
    -jobconf 	stream.num.map.output.key.fields=2					\
    -mapper  	"$HOME/ics/pool/social/network/twitter_friends/graph/gen_1hood.rb --map"	\
    -reducer	"$HOME/ics/pool/social/network/twitter_friends/graph/gen_1hood.rb --reduce" 	\
    -input      $input_file/a_follows_b.tsv						\
    -input      $input_file/a_replied_b.tsv						\
    -output  	$output_file								\
    -file    	hadoop_utils.rb								\
    -file    	twitter_flat_model.rb
    
# # Sort into keyed files
# hadoop jar $HOME/hadoop/h/contrib/streaming/hadoop-*-streaming.jar		\
#     -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 		\
#     -jobconf    map.output.key.field.separator='\t'				\
#     -jobconf    num.key.fields.for.partition=1 					\
#     -jobconf    stream.map.output.field.separator='\t'				\
#     -jobconf    stream.num.map.output.key.fields=3				\
#     -mapper     cat								\
#     -reducer	cat 								\
#     -input   	$mid_file 							\
#     -output  	$output_file
