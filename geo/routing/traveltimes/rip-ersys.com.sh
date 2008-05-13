cd ~/ics/code/munge/geo/routing/traveltimes/rawd/
for ((i=1;$i<=56;i++)) ; do st=`printf '%02d' $i`; idx=www.ersys.com/usa/$st/index.htm; if [ -f $idx ] ; then echo "Skipping $idx" ; else wget -nv -x "http://$idx" ; fi ; done
cat www.ersys.com/usa/*/index.htm | perl -ne 'for my $m (m!href=.(\d{7,7})/index.htm!g) { my ($st,) = ($m =~ m!^(\d\d)!); print "wget -x http://www.ersys.com/usa/$st/$m/distance.htm\n" }' | sort -u > rip-ersys-distances.sh
