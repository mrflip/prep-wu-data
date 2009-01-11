#!/usr/bin/env bash

echo "Scripts to copy and paste from.  Don't run me directly"
exit

#
# Copy all archives to the DFS
#
(
  cd /workspace/flip/data/arch/social/network/twitter_friends/ripd
  hdp-ls arch/ripd/* > ../arch-ripd-listing.txt
  for tarfile in ripd_*/* ; do
    if  [ -z "`grep $tarfile ../arch-ripd-listing.txt `" ] ; then
      echo "Copying $tarfile ";
      hdp-put $tarfile arch/ripd/$tarfile ;
    fi ;
  done
)


#
# Get a sampling of
#
dest=tmp/sample_tweets.tsv
rm $dest ;
for foo in  '#|[^"]http://|@'  '(RT|retweet|via).*@[A-Za-z0-9_]' \
  '(RT|retweet).*(please|plz|pls)' '(please|plz|pls).*RT|retweet)' ; do
  hdp-cat fixd/user/p\*0 | egrep "$foo" | head -n 200 >> $dest ;
done
