#!/usr/bin/env bash

in_hosts="rossby.ph.utexas.edu: womper.ph.utexas.edu: $MRFLIP: lab3:/workspace/flip"
out_hosts="lab2:/workspace/flip lab4:/workspace/flip lab6:/workspace/flip lab7:/workspace/flip"
base_dir=data/ripd/_com/_tw/com.twitter
timeline_dir=data/rawd/social/network/twitter_friends/public_timeline
localprefix=/workspace/flip

days="_20081220"
  # _20081126 _20081128 _20081130 _20081202 _20081204 _20081206 _20081208
  # _20081210 _20081212 _20081214 _20081216 _20081218 _20081220 _20081127
  # _20081129 _20081201 _20081203 _20081205 _20081207 _20081209 _20081211
  # _20081213 _20081215 _20081217 _20081219 "

#
# From
#
for host in $in_hosts  ; do
  for day in $days ; do
    echo collecting from $host $day;
    rsync -Cuvzrtlp --size-only $host/$base_dir/${day}/ $localprefix/$base_dir/${day}/ 
  done
done

#
# To
#
for host in $out_hosts $in_hosts ; do
  for day in $days ; do
    echo sending to $host $day;
    rsync -Cuvzrtlp --size-only $localprefix/$base_dir/${day}/ $host/$base_dir/${day}/
  done
done

# #
# # Timeline
# #
# tl_dir=$localprefix/$timeline_dir
# rsync -Cuvzrtlp rossby.ph.utexas.edu:/$timeline_dir/ $tl_dir/
# 
# for day in $tl_dir/*/* ; do
#     day_slug=`echo $day | ruby -ne 'a = $_.split("/")[-2..-1].join("") ; puts a'`
#     day_out_file=rawd/public_timeline/$day_slug.tsv
#     day_out_file_exists=`hdp-ls $day_out_file 2>/dev/null`
#     if [ "$day_out_file_exists" == "" ] ; then 
# 	echo "writing contents of $day to $day_out_file"
# 	find $day -type f -iname '*.json' -exec bash -c "cat {} ; echo" \; | hdp-put - $day_out_file
#     else
# 	echo "skipping ${day}: $day_out_file exists."
#     fi
# done
