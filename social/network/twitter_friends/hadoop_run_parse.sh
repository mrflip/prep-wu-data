#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers
input_id=${1-`datename`}
output_id=${2-`datename`}

mid_file=out/$output_id-parsed-uff
output_file=out/$output_id-sorted-uff
# Clear space
hdp-rm -r $mid_file $output_file

scripts_dir=$HOME/ics/pool/social/network/twitter_friends
parse_mapper_cmd="$scripts_dir/hadoop_parse_json.rb"
parse_reducer_cmd="$scripts_dir/hadoop_uniq_without_timestamp.rb"

# ./twitter_bundle_json.rb _`datename`
# for foo in rawd/keyed/*/*.tsv ; do hdp-put $foo $foo ; done

hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-*-streaming.jar	       	\
    -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner 			\
    -jobconf    map.output.key.field.separator='\t'					\
    -jobconf    num.key.fields.for.partition=1 						\
    -jobconf 	stream.map.output.field.separator='\t'					\
    -jobconf 	stream.num.map.output.key.fields=2					\
    -mapper  	"$parse_mapper_cmd --keyed"						\
    -reducer	"$parse_reducer_cmd"							\
    -input      rawd/keyed/_20081{126,127,128,129,130,201,202,203,204,205,206,207,208,209,210,211,212,213,215,216,217,218,219,220,221,222}/'*'					\
    -output  	"$mid_file"								\
    -file    	hadoop_utils.rb								\
    -file    	twitter_flat_model.rb							\
    -file    	twitter_autourl.rb

#  }/'*' \
# 	rawd/keyed/_20081126'/*',rawd/keyed/_20081127'/*',rawd/keyed/_20081128'/*',rawd/keyed/_20081129'/*',rawd/keyed/_20081130'/*',rawd/keyed/_20081201'/*',rawd/keyed/_20081202'/*',rawd/keyed/_20081203'/*',rawd/keyed/_20081204'/*',rawd/keyed/_20081205'/*',rawd/keyed/_20081206'/*',rawd/keyed/_20081207'/*',rawd/keyed/_20081208'/*',rawd/keyed/_20081209'/*',rawd/keyed/_20081210'/*',rawd/keyed/_20081211'/*',rawd/keyed/_20081212'/*',rawd/keyed/_20081212'/*',rawd/keyed/_20081213'/*' \

hdp-sort "$mid_file" "$output_file" /bin/cat /bin/cat 3 
