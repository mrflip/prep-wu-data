

data_root=/workspace/flip/data
rawd=$data_root/rawd/
rawd=$rawd_root/social/network/twitter_friends
ripd=$data_root/ripd/_com/_tw/com.twitter/

ripd_filenames=$rawd/ripd_files-`date +%Y%m%d%H%M%S`
find  -type f > $ripd_filenames

#!/usr/bin/env bash
# hadoop dfs -rmr out/parsed-followers


hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-0.19.0-streaming.jar		\
  -mapper  /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
  -reducer /home/flip/ics/pool/social/network/twitter_friends/sort_uniq.sh		\
  -input                  rawd/social/network/twitter_friends/'*'			\
  -output  out/parsed-2									\
  -file    hadoop_utils.rb								\
  -file    twitter_autourl.rb

#  -jobconf mapred.reduce.tasks=4
