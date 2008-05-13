for foo in `cat ../result-uniquefilenames.txt` ; do
    if `grep -Pq "$*" "$foo"*` ; then
	echo -n "$foo       " ;
	grep -Ph "$*"  "$foo"* |
	    cut -d',' -f1-3 |
	    cut -c 1-150 ;
    else
	echo $foo ;
    fi ;
done
