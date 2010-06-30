#!/usr/bin/env bash

# This will stream the data from the previous day past the parser.  In order to run in local mode without the tyrant or cassandra database,
# there is a NO_DB constant in each parser that needs to be set to true.  If it is false, it will try to send stuff to the db and will have problems.
# After the data is parsed the files will be bzipped and then uploaded to Amazon S3 into the directory:
# s3://infochimps-data/data/soc/net/tw/rawd/parsed/$yesterday


ripddir='/data/ripd/com.tw'
rawddir='/data/soc/net/tw/rawd/parsed'
logdir='/data/log/com.tw/'
yesterday=`date --date="yesterday" "+%Y%m%d"`
hostname=`hostname`

for foo in `ls -1d $ripddir/*/$yesterday`
do
  case $foo
  in
    $ripddir/com.twitter/$yesterday) echo Running API parse on $foo 
                                     mkdir -p $rawddir/$yesterday
                                     cat $foo/* | /home/doncarlo/ics/infochimps-data/social/network/twitter/base/parse/parse_twitter_api_requests.rb --map >> $rawddir/$yesterday/$hostname-comtwitter-parsed-$yesterday.tsv ;;
    $ripddir/com.twitter.search/$yesterday) echo Running search parse on $foo
                                            mkdir -p $rawddir/$yesterday
                                            cat $foo/* | /home/doncarlo/ics/infochimps-data/social/network/twitter/base/parse/parse_twitter_search_requests.rb --map >> $rawddir/$yesterday/$hostname-comtwittersearch-parsed-$yesterday.tsv ;;
    $ripddir/com.twitter.stream/$yesterday) echo Running stream parse on $foo
                                            mkdir -p $rawddir/$yesterday
                                            cat $foo/* | /home/doncarlo/ics/infochimps-data/social/network/twitter/base/parse/parse_twitter_stream_requests.rb --map >> $rawddir/$yesterday/$hostname-comtwitterstream-parsed-$yesterday.tsv ;;
  esac
done 2> $logdir/parse-stderr.log
  
# Bzip the resulting parsed data so it will be uploaded to Amazon S3 later
find $rawddir/$yesterday/* \( -name '*.tsv' \) -exec bzip2 {} \;

# Change group and permissions so people can read the resulting data
chgrp -R admin $rawddir
chmod -R g+w $rawddir
