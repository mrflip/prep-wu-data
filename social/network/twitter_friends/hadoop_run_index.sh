#!/usr/bin/env bash

# Where is the latest parsed build?
sorted_id=${1-`datename`}
output_id=${2-`datename`}

users_files=out/${sorted_id}-sorted-uff-a/twitter_user.tsv,out/${sorted_id}-sorted-uff-a/twitter_user_partial.tsv
listing_file=rawd/ripd_listings.tsv
mid_file=out/${output_id}-scrape_requests-tmp
output_file=out/${output_id}-scrape_requests

# scripts
script_dir=$HOME/ics/pool/social/network/twitter_friends
stage_1=$script_dir/hadoop_manage_requests.rb

#
# Clear the way
#
hdp-rm -r $mid_file $output_file

#
# index ripd file collection
#
hadoop dfs -rmr $listing_file
$HOME/ics/pool/social/network/twitter_friends/twitter_index_scraped_files.rb
cat rawd/ripd_listings/* | hdp-put - $listing_file

#
# Parse and assemble
#
hdp-stream $listing_file,$users_files  $mid_file 			\
    		"$stage_1 --map" "$stage_1 --reduce" 2 			\
  -file  	$script_dir/hadoop_utils.rb				\
  -file  	$script_dir/twitter_flat_model.rb
    
# Sort into keyed files
hdp-sort $mid_file $output_file /bin/cat /usr/bin/uniq 5 
