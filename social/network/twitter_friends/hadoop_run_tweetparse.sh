#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers
input_spec=${1-'*'}
output_name=${2-`datename`}

# scripts
scripts_dir=`dirname $0`
parse_mapper_cmd=`realpath "$scripts_dir/hadoop_parse_json.rb"`
parse_reducer_cmd=`realpath "$scripts_dir/hadoop_uniq_without_timestamp.rb"`

# output files
mid_file=out/$output_name-parsed-tweets
output_file=out/$output_name-sorted-tweets
# Clear space
hdp-rm -r $mid_file $output_file

# parse
hdp-stream rawd/public_timeline/$input_spec "$mid_file" "$parse_mapper_cmd --tweets" "$parse_reducer_cmd" 2 \
  -file hadoop_utils.rb -file twitter_flat_model.rb -file twitter_autourl.rb 

# aggregate
hdp-sort "$mid_file" "$output_file" /bin/cat /usr/bin/uniq 2 \
  -jobconf 	mapred.reduce.tasks=14
