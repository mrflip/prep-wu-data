icscaldir=~/rawd/time/calendar/holidays/mozilla-icals
xmlcaldir=~/rawd/time/calendar/holidays/mozilla-xml
fromical=$HOME/now/vizsage/apps/AuxData/calendar/holidays/dig-csail-mit-edu/fromIcal.py


for icscal in $icscaldir/*.ics ; do
    base=`basename "$icscal" .ics`
    tmpcal=/tmp/"$base".temp.ics 
    xmlcal="$xmlcaldir"/"$base".xml 

    echo "Processing '$icscal' => '$xmlcal'"

    cat "$icscal" | 
    	perl -e 'local $/; $_=<>;
		s!\s*([\:\;])\s*!$1!sig;
		s!TZID[\:=]/mozilla.org/[\w\/]+:!!ig ; 
		s!TZID\:/mozilla.org/(?:[\d_]+|BasicTimezones)/!TZID\:!ig ; 
		s!TZID\:.*GMT!TZID\:UTC!ig ; 
		s!EXDATE;.*!!ig ;
		s!(RECURRENCE-ID|DT(?:START|END));(?:VALUE=DATE[\;\:])?(.*\d+)(?:T\d+)?!$1:$2T000000Z!ig; 
		print; ' > "$tmpcal"
	"$fromical" --notimezone "$tmpcal"  | xmltidy.sh - > $xmlcal

	if ! ( xmllint --noout "$xmlcal" 2>/dev/null ) ; then exit ; fi
done

for xmlcal in $xmlcaldir/*.xml ; do
  	if ( xmllint --noout "$xmlcal" 2>/dev/null ) ; then
		true;
	else 
		echo "no:  $xmlcal"
		mv "$xmlcal" "$xmlcaldir"/bad
	fi
done
