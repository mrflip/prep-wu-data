# must include trailing / on URL

# for month in 10 09 ; do
#     wget -erobots=off -r -l7 --no-clobber --relative --no-parent \
# 	-Axml,txt --no-host-directories --cut-dirs=1 --limit-rate=25k \
# 	-nv -a /work/DataSources/Data_MLB/wget-`datename`.log \
# 	--random-wait -w 0.2 \
# 	http://gd2.mlb.com/components/game/mlb/year_2007/month_$month/
#     # !! make sure to include trailing / on URL !!
# done

for league in aaa afa asx ind milb mlb playertracker rok year_2006 aax afx bbc int min oly protected win year_2007 ; do
    wget -erobots=off -r -l8 --no-clobber --relative --no-parent \
	-Axml,txt --no-host-directories --cut-dirs=1 \
	-nv -a /work/DataSources/Data_MLB/wget-`datename`.log \
	--limit-rate=25k  \
	http://gd2.mlb.com/components/game/${league}/
done

# --random-wait -w 0.2

