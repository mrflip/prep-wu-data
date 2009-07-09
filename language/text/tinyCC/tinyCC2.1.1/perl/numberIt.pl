#!/usr/bin/perl -w

# numberIt.pl: numbers sentences
# by Chris Biemann, Feb 2006
#
#
# script detetes 2nd col from mycorpus.sentence-separated.txt
# usage
if (@ARGV ne 1) {die "Parameters (1) sentences > out";}

open(FILE,"<$ARGV[0]");



while($in=<FILE>) {
 @a=split(/\t/,$in);  
 print "$a[0]\t$a[2]";
   

} # ehliw in

close(FILE);


exit();