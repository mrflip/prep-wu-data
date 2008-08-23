# must include trailing / on URL

# for league in aaa afa asx ind milb mlb playertracker rok year_2006 aax afx bbc int min oly protected win year_2007 ; do
#     wget -erobots=off -r -l8 --no-clobber --relative --no-parent \
# 	-Axml,txt --no-host-directories --cut-dirs=1 \
# 	-nv -a /work/DataSources/Data_MLB/wget-`datename`.log \
# 	--limit-rate=25k  \
# 	http://gd2.mlb.com/components/game/${league}/
# done

# http://gd2.mlb.com/components/game/mlb/year_2008/month_07/day_06/gid_2008_07_06_flomlb_colmlb_1/pbp/pitchers/150430.xml
#                                    0   1         2        3       4                             5   6        7  

#     oly aaa afa asx ind rok aax afx bbc int min win milb playertracker year_2006 year_2007 protected 
logdir="/data/log/sport/baseball/mlb_gameday"
ripdir="/data/ripd"
gd_url="gd2.mlb.com/components/game"
mkdir -p $logdir
cd $ripdir

# # get the top-level directories
# wget -r -l3 --no-clobber --relative --no-parent \
#     -Axml,txt -nv -a $logdir/wget-`datename`.log \
#     --random-wait -w0.5 \
#     http://$gd_url/
# | egrep -v 'year_200[567]' | egrep -v 'aaa/year_2008/month_0[123456]
dirs=`find $gd_url -maxdepth 3 -mindepth 3 -type d | grep 'month_' `
echo scraping `find $gd_url -maxdepth 3 -mindepth 3 -type d | grep 'month_' | cut -d/ -f4,5,6`

for league_year_mo in $dirs ; do
  wget -r -l9 --no-clobber --relative --no-parent \
    -Axml,txt -nv -a $logdir/wget-`datename`.log \
    --random-wait -w1.0  \
    http://$league_year_mo/
    # !! make sure to include trailing / on URL !!
done

