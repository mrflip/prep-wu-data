#!/usr/bin/env bash

in_hosts="$MRFLIP: rossby.ph.utexas.edu: womper.ph.utexas.edu:"
out_hosts="lab2:/workspace/flip lab3:/workspace/flip  "
base_dir=data/ripd/_com/_tw/com.twitter
timeline_dir=data/rawd/social/network/twitter_friends/public_timeline
localprefix=/workspace/flip

days="_20081231 _20081230 _20081229 _20081228 _20081227 _20081226 _20081225 _20081224 _20081223 _20081222"
  # _20081126 _20081128 _20081130 _20081202 _20081204 _20081206 _20081208
  # _20081210 _20081212 _20081214 _20081216 _20081218 _20081220 _20081127
  # _20081129 _20081201 _20081203 _20081205 _20081207 _20081209 _20081211
  # _20081213 _20081215 _20081217 _20081219 _20081220"

#
# From
#
for day in $days ; do
  for host in $in_hosts  ; do
    echo collecting from $host $day;
    rsync -Cvuzrtlp --size-only $host/$base_dir/${day}/ $localprefix/$base_dir/${day}/ 
  done
done

#
# To
#
for host in $out_hosts  ; do
  for day in $days ; do
    echo sending to $host $day;
    rsync -Cuvzrtlp --size-only $localprefix/$base_dir/${day}/ $host/$base_dir/${day}/
  done
done

