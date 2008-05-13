#!/bin/bash

# get symbol names
echo "Downloading symbol lists."
# wget -nc 'http://www.nasdaq.com//asp/symbols.asp?exchange=Q&start=0' -O Symbol-Name-NASDAQ-all.csv
# wget -nc 'http://www.nasdaq.com//asp/symbols.asp?exchange=1&start=0' -O Symbol-Name-AMEX-all.csv
# wget -nc 'http://www.nasdaq.com//asp/symbols.asp?exchange=N&start=0' -O Symbol-Name-NYSE-all.csv

sedNASDAQ='s/"([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)",(.*)/<symbol name="$1" symbol="$2" sectype="$3" sharesoutstanding="$4" marketvalueM="$5" /gso'
sedAMEX='s/"([^"]*)","([^"]*)","([^"]*)",(.*)$/<symbol name="$1" symbol="$2" sectype="" sharesoutstanding="" marketvalueM="$3" /gso'
sedNYSE='s/"([^"]*)","([^"]*)","([^"]*)",(.*)$/<symbol name="$1" symbol="$2" sectype="" sharesoutstanding="" marketvalueM="$3" /gso'
tailNASDAQ='$6'
tailAMEX='$4'
tailNYSE='$4'



for exchg in NASDAQ AMEX NYSE ; do 
  echo "Snarfing ${exchg}..."
  sedvar=sed${exchg}; sed=${!sedvar}; tailvar=tail${exchg}; tailmatch=${!tailvar};
  # echo $tailmatch $sed;
  outfile="New-Symbol-Name-${exchg}-all.xml"
  cat Symbol-Name-${exchg}-all.csv | \
    perl -e 'local $/; $_=<>; tr/\x00-\x7f\x93\x94//cd; 
    	print "<symbols>\n"; 
    	for $line (split "\x0d\x0a",$_) { 
    		next unless $line =~ '"${sed}"'; 
    		$head=$line; 
    		$tail='"${tailmatch}"'; 
    		$tail=~tr/\x0d\x0a"\x93\x94/  '"'''"'/; 
    		($desc,$url) = ($tail=~m{(.*?)(?:&nbsp;&nbsp;\.\.\. )?More\.\.\.'"''"'(http://[^&]*)'"''"'[ <>/a&nbsp;'"'"']+([\w\.]+</a>)?.$}); 
    		($desc,$url)=($tail,"",) unless $desc; 
    		$desc=~s/(&nbsp;)//g; $desc=~s/&/&amp;/g; $desc=~s/</&lt;/g; $desc=~s/>/&gt;/g; 
    		# $desc=~s!</?[^<]+>!!g; 
    		$head=~s/&/&amp;/g; 
    		print "$head desc=\"$desc\" url=\"$url\"/>\n";
    	}; 
    	print "</symbols>"; '> $outfile
	    #Symbol-Name-${exchg}-all.xml
  echo -n `xml val $outfile` " - "
  echo -n `xml sel -t -m '//symbol' -v '@symbol' -n  $outfile |wc -l`
  echo ' lines.'
done
