#!/usr/bin/env bash
poolpath="social/network/twitter_friends/public_timeline"
datadir="/data/rawd/${poolpath}"
logdir="/data/log/${poolpath}"

public_url="http://twitter.com/statuses/public_timeline.json"
trends_url="http://search.twitter.com/trends.json"
waittime=59

mkdir -p $logdir
mkdir -p $datadir
cd       $datadir
for (( i=0 ; 1 ; true )) ; do
    logname=$logdir/`date +'twitter_public_timeline-%Y%m%d.log'`
    datedir=$datadir/`date +'%Y%m/%d/%H'`
    datetime=`date +'%Y%m%d-%H%M%S'`
    mkdir -p `dirname $logname`
    mkdir -p `dirname $datedir`
    public_filename=
    wget -nc -nv -a $logname $public_url -O $datedir/public_timeline-$datetime.json
    wget -nc -nv -a $logname $trends_url -O $datedir/trends-$datetime.json
    sleep $waittime
    true
done

