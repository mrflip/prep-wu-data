#!/usr/bin/env bash

in_hosts="rossby.ph.utexas.edu: womper.ph.utexas.edu: $MRFLIP: "
out_hosts="lab2:/workspace/flip lab3:/workspace/flip "
base_dir=data/ripd/_com/_tw/com.twitter
timeline_dir=data/rawd/social/network/twitter_friends/public_timeline
localprefix=/workspace/flip

days="_20081220"

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

#
# Timeline
#
tl_dir=$localprefix/$timeline_dir
rsync -Cuvzrtlp rossby.ph.utexas.edu:/$timeline_dir/ $tl_dir/

for day in $tl_dir/*/* ; do
    day_slug=`echo $day | ruby -ne 'a = $_.split("/")[-2..-1].join("") ; puts a'`
    day_out_file=rawd/public_timeline/$day_slug.tsv
    day_out_file_exists=`hdp-ls $day_out_file 2>/dev/null`
    if [ "$day_out_file_exists" == "" ] ; then 
	echo "writing contents of $day to $day_out_file"
	find $day -type f -iname '*.json' -exec bash -c "cat {} ; echo" \; | hdp-put - $day_out_file
    else
	echo "skipping ${day}: $day_out_file exists."
    fi
done
