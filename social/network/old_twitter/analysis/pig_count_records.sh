#!/usr/bin/env bash

output=out/wcl-`date +%Y%m%d%H%M%S`

cmd="
  AllRecords   	   = load '$1' using PigStorage('\t');
  RecordTypes 	   = GROUP AllRecords by \$0;
  RecordTypeCounts = FOREACH RecordTypes {
    record  = AllRecords.\$0;
    GENERATE COUNT(record), FLATTEN(group); };
  store RecordTypeCounts into '$output';  "
  
echo $cmd ; read -p "That look about right? ^C or hit return ..."
echo $cmd | pig
echo "Dumped to $output"
hadoop dfs -cat "$output/part-*" | head 
