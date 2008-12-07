#!/usr/bin/env bash
data_root=/workspace/flip/data
ripd=$data_root/ripd/_com/_tw/com.twitter
rawd=$data_root/rawd/social/network/twitter_friends
temp=$data_root/temp/social/network/twitter_friends

runid=$1
hdfs_dest=rawd/social/network/twitter_friends-$runid
hdp-mkdir $hdfs_dest
echo "Copying into $hdfs_dest"

cd $rawd/keyed
echo users     ; (for dir in users/show/*         ; do cat $dir/* ; done ) | hdp-put - $hdfs_dest/users_show.tsv
echo friends   ; (for dir in statuses/friends/*   ; do cat $dir/* ; done ) | hdp-put - $hdfs_dest/statuses_friends.tsv
echo followers ; (for dir in statuses/followers/* ; do cat $dir/* ; done ) | hdp-put - $hdfs_dest/statuses_followers.tsv

# cd $rawd/keyed
# for dir1 in * ; do
#     cd $rawd/keyed/$dir1
#     for dir2 in * ; do	
# 	echo '==========================================================================='
# 	echo $dir1 - $dir2
# 	echo '==========================================================================='; echo
# 	for prfx in $dir2/_Ma ; do
# 	    echo -n "$dir	"
# 	    cat $prfx/* | hdp-put - $hdfs_dest/`basename $dir1`-`basename $dir2`-`basename $prfx`.tsv
# 	done
#     done
# done

# hadoop jar /home/flip/hadoop/h/contrib/streaming/hadoop-0.19.0-streaming.jar		\
#   -mapper  /home/flip/ics/pool/social/network/twitter_friends/hadoop_parse_json.rb	\
#   -reducer /home/flip/ics/pool/social/network/twitter_friends/sort_uniq.sh		\
#   -input                  rawd/social/network/twitter_friends/'*'			\
#   -output  out/parsed-2									\
#   -file    hadoop_utils.rb								\
#   -file    twitter_autourl.rb
# 
# #  -jobconf mapred.reduce.tasks=4
