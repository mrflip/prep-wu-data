
urldiv='http://ichart.finance.yahoo.com/table.csv?ignore=.csv&g=v&s='
urlstk='http://ichart.finance.yahoo.com/table.csv?ignore=.csv&g=d&s='
begdate='&a=0&b=1&c=1900'
enddate=`date +'&d=%d&e=%m&f=%Y'`

codedir=$HOME/ics/code/munge/money/stocks/stocks_yahoo
datadir=$HOME/ics/data
rawd=$datadir/rawd/money/stocks/stocks_yahoo
mkdir -p ${rawd}
cd ${rawd} 


logfile=${rawd}/snarf-yahoo.`datename`.log

for exchg in AMEX NYSE NASDAQ ; do 
    symnames=${codedir}/Symbol-Name-${exchg}-all.xml
    for ltr in A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 0 ; do
	mkdir -p ${rawd}/${exchg}-${ltr}
	for symbol in `xml sel -t -m '//symbol' -v '@symbol' -n  ${symnames} | grep -Pi '^'${ltr}'\w+\$'` ; do
	    file=${rawd}/${exchg}-${ltr}/Symbol-Div-${exchg}-${symbol}.csv
	    if [ -a ${file} ] ; then
		echo "Skipping $file" >> ${logfile}
	    else
		wget --waitretry=2 --wait=1 --random-wait --limit-rate=125k -a ${logfile} -nc ${urldiv}${symbol}${begdate}${enddate} -O ${file}
		#zzz=$(( $RANDOM /(1024) ))
		#echo "Sleeping for $zzz..." >> ${logfile}
	    fi

	    file=${rawd}/${exchg}-${ltr}/Symbol-Stk-${exchg}-${symbol}.csv
	    if [ -a ${file} ] ; then
		echo "Skipping $file" >> ${logfile}
	    else
		wget --waitretry=2 --wait=1 --random-wait --limit-rate=125k -a ${logfile} -nc ${urlstk}${symbol}${begdate}${enddate} -O ${file}
		#zzz=$(( $RANDOM /(1024) ))
		#echo "Sleeping for $zzz..." >> ${logfile}
		#sleep $zzz
	    fi
	done
    done
done
