#!/usr/bin/env bash

# all_base_files=fixd/user,fixd/friends,fixd/followers,fixd/favorites,fixd/public_timeline
# all_fixd_files="$all_base_files",fixd/text_elements

query="$1"
src_path="$2"

if    [ "$query" == "" ] ; then
  echo "Need a query to run"
elif [ "$query" == "objects_frequency" ] ; then
  dest=metrics/$query
  hdp-rm -r $dest
  hdp-stream-flat $src_path $dest \
    `realpath queries/objects_frequency-mapper.sh` '/usr/bin/uniq -c' \
    -jobconf mapred.reduce.tasks=10
else
  echo "Don't know how to do query $query"
fi
