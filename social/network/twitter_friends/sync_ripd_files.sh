#!/usr/bin/env bash

in_hosts="rossby.ph.utexas.edu: womper.ph.utexas.edu: $MRFLIP: "
out_hosts="lab2:/workspace/flip lab3:/workspace/flip "
base_dir=data/ripd/_com/_tw/com.twitter
timeline_dir=data/rawd/social/network/twitter_friends/public_timeline
localprefix=/workspace/flip

#
# From
#
for host in $in_hosts  ; do
  for day in _20081218 ; do
    echo $day;
    rsync -Cuvzrtlp $host/$base_dir/${day}/ $localprefix/$base_dir/${day}/ 
  done
done

#
# To
#
for host in $out_hosts  ; do
  for day in _20081218 ; do
    echo $day;
    rsync -Cuvzrtlp $localprefix/$base_dir/${day}/ $host/$base_dir/${day}/
  done
done

#
# Bundle
#


#
# Timeline
#
tl_dir=$localprefix/$timeline_dir
rsync -Cuvzrtlp rossby.ph.utexas.edu:/$timeline_dir $tl_dir

for day in $tl_dir/*/* ; do
    day_slug=`echo $day | ruby -ne 'a = $_.split("/")[-2..-1].join("") ; puts a'`
    day_out_file=rawd/public_timeline/$day_slug.tsv
    day_out_file_exists=`hdp-ls $day_out_file 2>/dev/null`
    if [ "$day_out_file_exists" == "" ] ; then 
	echo "writing contents of $day to $day_out_file"
	find $day -type f -exec cat {} \; | hdp-put - $day_out_file
    else
	echo "skipping ${day}: $day_out_file exists."
    fi
done
