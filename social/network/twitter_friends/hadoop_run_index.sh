#!/usr/bin/env bash

# Where is the latest parsed build?
input_id=${1-`datename`}
output_id=${1-`datename`}

mid_file=out/scrape_requests-$output_id-tmp
users_files=out/sorted-$input_id/twitter_user.tsv,out/sorted-$input_id/twitter_user_partial.tsv
listing_file=rawd/ripd_listings.tsv
output_file=out/"scrape_requests-$output_id"

#
# Clear the way
#
# hadoop dfs -rmr $listing_file
hdp-rm -r $mid_file $outputfile

#
# index ripd file collection
#
$HOME/ics/pool/social/network/twitter_friends/twitter_index_scraped_files.rb
# cat rawd/ripd_listings/* | hdp-put - $listing_file

#
# Parse and assemble
#
hadoop jar $HOME/hadoop/h/contrib/streaming/hadoop-*-streaming.jar			\
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 			\
    -jobconf    map.output.key.field.separator='\t'					\
    -jobconf    num.key.fields.for.partition=1 						\
    -jobconf 	stream.map.output.field.separator='\t'					\
    -jobconf 	stream.num.map.output.key.fields=2					\
    -mapper  	$HOME/ics/pool/social/network/twitter_friends/hadoop_manage_requests.rb	\
    -reducer	$HOME/ics/pool/social/network/twitter_friends/hadoop_manage_requests_reduce.rb \
    -input      $listing_file								\
    -input      $users_files 								\
    -output  	$mid_file								\
    -file    	hadoop_utils.rb								\
    -file    	twitter_flat_model.rb
    
# Sort into keyed files
hadoop jar $HOME/hadoop/h/contrib/streaming/hadoop-*-streaming.jar		\
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 		\
    -jobconf    map.output.key.field.separator='\t'				\
    -jobconf    num.key.fields.for.partition=1 					\
    -jobconf    stream.map.output.field.separator='\t'				\
    -jobconf    stream.num.map.output.key.fields=3				\
    -mapper     cat								\
    -reducer	cat 								\
    -input   	$mid_file 							\
    -output  	$output_file
