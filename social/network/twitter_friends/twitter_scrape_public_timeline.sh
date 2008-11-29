#!/usr/bin/env bash
poolpath="social/network/twitter_friends/public_timeline"
datadir="/data/rawd/${poolpath}"
logdir="/data/log/${poolpath}"
url="http://twitter.com/statuses/public_timeline.json"
waittime=3

mkdir -p $logdir
mkdir -p $datadir
cd       $datadir
for (( i=0 ; 1 ; true )) ; do
    filename=$datadir/`date +'%Y%m/%d/%H%M/public_timeline-%Y%m%d-%H%M%S.json'`
    logname=$logdir/`date +'twitter_public_timeline-%Y%m%d.log'`
    mkdir -p `dirname $filename`
    mkdir -p `dirname $logname`
    wget -nc -nv -a $logname $url -O $filename
    sleep $waittime
    true
done
