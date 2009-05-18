#!/usr/bin/perl -w

# tokenizeConvert.pl: Tokenizer of unsuPOS-System
# by Chris Biemann, Feb 2006
#
#
# Script writes a frequency word list, sorted desc by word frequency
# it takes as input space-tokenized text (the output of tokenizeConvert.pl)
#
#
#
# verbose: $infostep is progress step
$multistep=100000; # multiwords
$infostep=10000; # sentences
#
# usage
if (@ARGV ne 4) {die "Parameters (4): single-wordlist multi-wordlist tokenized-numbered-textfile word-freq-outfile";}

open(OUT,">$ARGV[3]");


# read single words
open(SWL,"<$ARGV[0]"); 
%singword=();

while($in=<SWL>) {
  chomp($in);
#  print "defined: $in\n";
  $singword{$in}=0;
}
close(SWL);

$maxparts=0;

# read multiwords: only one swhose parts are present
open(MWL, "<$ARGV[1]");
%multword=();

$multi_nr=0;

while($in=<MWL>) {
  chomp($in);

   $multi_nr++;

   if (($multi_nr%$multistep) eq 0) {print "[freqMulti] $ARGV[1] at line $multi_nr\n";}


  @a=split(/\s/,$in);
  $flag=1;
#  print "\nMulti: $in";
  for ($i=0;$i<@a;$i++) {
     if (!(defined $singword{$a[$i]})) {
      if (!(($a[$i]=~m/[0-9]/)&&(!($a[$i]=~m/[A-Za-z]/)))) {
        $flag=0; 
        # print " undefined: $a[$i]"; 
      } #fi not number 
     }    
  }

  if ($flag eq 1) {

     if (@a>$maxparts) {$maxparts=@a;}

#     print "adding: $in\n";
     $multword{$in}=0;
  }
}



sub hashValueDescendingNum {
   $wordhash{$b} <=> $wordhash{$a};
}

open(TEXT,"<$ARGV[2]");

$line_nr=0;

%wordhash=();
while($in=<TEXT>) {
   chomp($in);
   @a=split(/\t/,$in);
   if (($a[0]=~m/[0-9]/)&&(!($a[0]=~m/[A-Za-z]/))) {
     $in="";
     for($pp=1;$pp<@a;$pp++) {$in=$in.$a[$pp];}
   }

   @w=split(/\s+/,$in);
   
   $line_nr++;

   if (($line_nr%$infostep) eq 0) {print "[freqMulti] $ARGV[2] at line $line_nr\n";}
   
   # single counts
   for($i=0;$i<@w;$i++) {
    #numbers
    if (($w[$i]=~m/[0-9]/)&&(!($w[$i]=~m/[A-Za-z]/))) {
      $singword="_NUMBER_";
    } else {
      $singword=$w[$i];
    }
      
    
    if (length($singword)>0) {
     if (defined $wordhash{$singword}) {
       $wordhash{$singword}++;
     }else { 
       $wordhash{$singword}=1;
     }
   }}


   # multiple counts
   for($i=0;$i<@w-1;$i++) {
     for($len=1;$len<$maxparts;$len++) {
       if (($i+$len)<@w) {
          $testword=$w[$i];
          for ($j=1;$j<=$len;$j++) {
            $testword="$testword $w[$i+$j]"
          }
    
          if (defined $multword{$testword}) {
#          print "found: $testword\n";
            
            if (defined $wordhash{$testword}) {
               $wordhash{$testword}++;
            }else { 
               $wordhash{$testword}=1;
           }
          
          
          }
       } 
     
     }
   
   } # rof
   
   
}

close(TEXT);



foreach $key (sort hashValueDescendingNum (keys %wordhash)) {
  print OUT "$wordhash{$key}\t$key\n";

}


close(OUT);



exit();