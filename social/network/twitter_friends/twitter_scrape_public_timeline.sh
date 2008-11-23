#!/usr/bin/env bash
poolpath="social/network/twitter_friends/public_timeline"
datadir="/data/rawd/${poolpath}"
logdir="/data/log/${poolpath}"
url="http://twitter.com/statuses/public_timeline.rss"
waittime=3

mkdir -p $logdir
mkdir -p $datadir
cd       $datadir
for (( i=0 ; 1 ; true )) ; do
    filename=$datadir/`date +'%Y%m/%d/%H%M/public_timeline-%Y%m%d-%H%M%S.rss'`
    logname=$logdir/`date +'twitter_public_timeline-%Y%m%d.log'`
    echo wget -nc -nv -a $logname $url -O $filename
    sleep $waittime
    true
done
