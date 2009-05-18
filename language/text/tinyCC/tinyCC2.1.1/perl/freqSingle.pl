#!/usr/bin/perl -w

# tokenizeConvert.pl: Tokenizer of unsuPOS-System
# by Chris Biemann, Feb 2006
#
#
# Script writes a frequency word list, sorted desc by word frequency
# it takes as input space-tokenized text (the output of tokenize.pl)
#
#
# verbose_ infostep is progressbar step
$info_step=10000;

#
# usage
if (@ARGV ne 2) {die "Parameters (2): tokenized-textfile singelwordlist-outfile";}

open(FILE,"<$ARGV[0]"); 
open(OUT,">$ARGV[1]");

sub hashValueDescendingNum {
   $wordhash{$b} <=> $wordhash{$a};
}


%wordhash=();

$line_nr=0;
while($in=<FILE>) {

   chomp($in);
   @a=split(/\t/,$in);
   if (($a[0]=~m/[0-9]/)&&(!($a[0]=~m/[A-Za-z]/))) {
     $in="";
     for($pp=1;$pp<@a;$pp++) {$in=$in.$a[$pp];}
   }

   $line_nr++;

   if (($line_nr%$info_step) eq 0) {print "[freqSingle] $ARGV[0] at line $line_nr\n";}

   @w=split(/\s+/,$in);
   for($i=0;$i<@w;$i++) {
    
    # numbers
    if (($w[$i]=~m/[0-9]/)&&(!($w[$i]=~m/[A-Za-z]/))) {$w[$i]="_NUMBER_";}
    
   
   
    if (length($w[$i])>0) {
     if (defined $wordhash{$w[$i]}) {
       $wordhash{$w[$i]}++;
     }else { 
       $wordhash{$w[$i]}=1;
     }
   }}
}

close(FILE);

foreach $key (sort hashValueDescendingNum (keys %wordhash)) {
  print OUT "$key\n";

}

close(OUT);


exit();