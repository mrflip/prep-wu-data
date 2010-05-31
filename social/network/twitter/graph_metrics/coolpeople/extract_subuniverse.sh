#!/usr/bin/env bash

user_id=15748351 # infochimps
hood_hdfs_dir=/data/sn/tw/cool/infochimps_hood
hood_local_dir=/mnt/tmp/infochimps_hood
mkdir -p $hood_local_dir

echo $user_id                                 > $hood_local_dir/n_n0.tsv
for rel in e_FOi e_FOo e_REi e_REo ; do
  hadoop fs -cat $hood_hdfs_dir/${rel}/part\* > $hood_local_dir/${rel}.tsv
done


( echo $user_id ;
  cat $hood_local_dir/{e_FOi,e_REi}.tsv | cuttab 2 ;
  cat $hood_local_dir/{e_FOo,e_REo}.tsv | cuttab 2 ;
  ) | sort -u -n > $hood_local_dir/n_ALL01.tsv
wc -l $hood_local_dir/*
hadoop fs -put $hood_local_dir/n_ALL01.tsv $hood_hdfs_dir/n_ALL01


# Collect user objects to local dir
for foo in twitter_user_n01 twitter_user_partial_n01 twitter_user_profile_n01 twitter_user_style_n01 ; do
  echo $foo ;
  hdp-catd $hood_hdfs_dir/${foo} > $hood_local_dir/${foo}.tsv &
done
# Get screen names
cat $hood_local_dir/twitter_user_partial_n01.tsv $hood_local_dir/twitter_user_n01.tsv | cuttab 4 > $hood_local_dir/screen_name_n01.tsv
hadoop fs -put $hood_local_dir/screen_name_n01.tsv $hood_hdfs_dir/screen_name_n01

cat $hood_local_dir/screen_name_n01.tsv $hood_local_dir/n_ALL01.tsv | hadoop fs -put -  $hood_hdfs_dir/ids_and_names_n01
