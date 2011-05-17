#!/usr/bin/env bash

dest_file=/foo/strata_snippets.txt 
ripd_root=/data/old_ripd
base_url=strataconf.com/strata2011/public/schedule

cd $ripd_root
# rm ${base_url}/full*
# wget -rl1 -pk -nc http://${base_url}/full 

echo -n > $dest_file 
for foo in $ripd_root/$base_url/detail/* ; do
  ( echo "`basename $foo`	" ;
    egrep -A3 '(class="(summary|en_grade_average_detail|session_time|tags|en_session_desc)|meta name="(description|author)|<title>)' $foo
  ) | ruby -e 'puts $stdin.read.gsub(/[\n\r]+/," ")' >> $dest_file 
done  
cat $dest_file | \
  ruby -ne '$_ =~ %r{^(\d+)\s.*"summary">([^<]+)<.*class="en_grade_average_detail">([^<]+)<}; puts [$3, $1, $2].join("\t")' | sort -n
