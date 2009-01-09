#!/usr/bin/env bash

echo "Scripts to copy and paste from"
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
