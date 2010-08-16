#!/usr/bin/env bash

# must include trailing / on URL

# for league in aaa afa asx ind milb mlb playertracker rok year_2006 aax afx bbc int min oly protected win year_2007 ; do
#     wget -erobots=off -r -l8 --no-clobber --relative --no-parent \
# 	-Axml,txt --no-host-directories --cut-dirs=1 \
# 	-nv -a /work/DataSources/Data_MLB/wget-`datename`.log \
# 	--limit-rate=25k  \
# 	http://gdx.mlb.com/components/game/${league}/
# done

# http://gdx.mlb.com/components/game/mlb/year_2008/month_07/day_06/gid_2008_07_06_flomlb_colmlb_1/pbp/pitchers/150430.xml
#                                    0   1         2        3       4                             5   6        7  

#     oly aaa afa asx ind rok aax afx bbc int min win milb playertracker year_2006 year_2007 protected 
logdir="/data/log/sport/baseball/mlb_gameday"
ripdir="/data/old_ripd"
gd_url="gdx.mlb.com/components/game"
mkdir -p $logdir
cd $ripdir

# # get the top-level directories
# wget -r -l2 --no-clobber --relative --no-parent \
#     -Axml,txt -nv -a $logdir/wget-`datename`.log \
#     --random-wait -w0.2 \
#     http://$gd_url/mlb/


# dirs=`find $gd_url -maxdepth 3 -mindepth 3 -type d | grep 'month_' `
dirs=$gd_url/mlb
echo scraping $dirs

for league_year_mo in $dirs/year_2008/month_{08,09,10,11,12}  $dirs/year_20{09,10}/month_* ; do
  wget -r -l9 --no-clobber --relative --no-parent \
    -Axml,txt -nv -a $logdir/wget-`datename`.log \
    --random-wait -w1.0  \
    http://$league_year_mo/
    # !! make sure to include trailing / on URL !!
done

