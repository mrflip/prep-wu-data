#!/bin/bash

datadir=./data
zipdir=~/infochimp/rawd/sites/download.geonames.org/export/dump/

for foo in $zipdir/*.zip ; do
    outdir=$datadir/`basename $foo .zip`
    mkdir -p $outdir
    unzip -o $foo -d $outdir
done

cp $zipdir/*.txt $datadir/

wget http://forum.geonames.org/gforum/posts/list/437.page       -O $datadir/geonames-currencylist-fromforums.html
wget http://geonames.cvs.sourceforge.net/*checkout*/geonames/data/countries.txt -O $datadir/geonames-countryinfo-morefromcvs.txt
