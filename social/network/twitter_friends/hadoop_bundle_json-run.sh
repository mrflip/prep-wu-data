#!/usr/bin/env bash
data_root=/workspace/flip/data
ripd=$data_root/ripd/_com/_tw/com.twitter
rawd=$data_root/rawd/social/network/twitter_friends
temp=$data_root/temp/social/network/twitter_friends

datestamp=`date +%Y%m%d`


cd $rawd/keyed
for part in */* ; do
  flat_dir=$temp/flat-$datestamp
  mkdir -p $flat_dir/$part
  
  echo '==========================================================================='
  echo $part
  echo '==========================================================================='; echo
  for dir in $part/* ; do
    echo $dir
    cat $dir/* > $flat_dir/$dir.tsv
  done
done

hdfs_dest=rawd/social/network/twitter_friends/
hdp-mkdir $hdfs_dest/
echo "hdp-cp $rawd/flat-$datestamp $hdfs_dest"


ls $rawd
echo $rawd

# hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-0.19.0-streaming.jar		\
#   -mapper  /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
#   -reducer /home/flip/ics/pool/social/network/twitter_friends/sort_uniq.sh		\
#   -input                  rawd/social/network/twitter_friends/'*'			\
#   -output  out/parsed-2									\
#   -file    hadoop_utils.rb								\
#   -file    twitter_autourl.rb
# 
# #  -jobconf mapred.reduce.tasks=4
