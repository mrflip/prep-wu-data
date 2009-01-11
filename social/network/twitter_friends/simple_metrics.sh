#!/usr/bin/env bash

all_base_files=fixd/user,fixd/friends,fixd/followers,fixd/favorites,fixd/public_timeline
all_fixd_files="$all_base_files",fixd/text_elements

# !!!!!!!!!!!!!!!!!!!!
#
all_fixd_files=fixd/text_elements/p\*00000
#
# !!!!!!!!!!!!!!!!!!!!

query="$1"

if    [ "$query" == "" ] ; then
  echo "Need a query to run"
elif [ "$query" == "objects_frequency" ] ; then
  hdp-stream-flat $all_fixd_files metrics/$query \
    '/usr/bin/cut -d"	" -f1 | cut -d"-" -f1' '/usr/bin/uniq -c'
else
  echo "Don't know how to do query $query"
fi
