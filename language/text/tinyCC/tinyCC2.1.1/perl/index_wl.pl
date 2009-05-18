#!/usr/bin/perl -w

# index: takes single+multi word list and numbered sentence file  and writes
#  - word list: w_nr, word, freq
#  - index: w_nr, s_nr
# by Chris Biemann, MAr 2006
#
# verbose
$infostep=10000;
#
#
# usage
if (@ARGV ne 3) {die "Parameters (2): freq-wordlist tokenized-textfile outname";}

open(INDEX,">$ARGV[2].index");
open(WLNR,">$ARGV[2].wordlist_tok");

# word numbers: special chars
$spec{"!"}=1;
$spec{"\""}=2;
$spec{"#"}=3;
$spec{"\$"}=4;
$spec{"%"}=5;
$spec{"&"}=6;
$spec{"'"}=7;
$spec{"("}=8;
$spec{")"}=9;
$spec{"*"}=10;
$spec{"+"}=11;
$spec{","}=12;
$spec{"-"}=13;
$spec{"."}=14;
$spec{"/"}=15;
$spec{":"}=16;
$spec{";"}=17;
$spec{"<"}=18;
$spec{"="}=19;
$spec{">"}=20;
$spec{"?"}=21;
$spec{"@"}=22;
$spec{"["}=23;
$spec{"\\"}=24;
$spec{"]"}=25;
$spec{"^"}=26;
$spec{"_"}=27;
$spec{"¤"}=28;
$spec{"}"}=29;
$spec{"|"}=30;
$spec{"}"}=31;
$spec{"~"}=32;
$spec{"`"}=33;
$spec{"´"}=34;
$spec{"§"}=35;
$spec{"¨"}=36;
$spec{"©"}=37;
$spec{"ª"}=38;
$spec{"«"}=39;
$spec{"¬"}=40;
$spec{"®"}=41;
$spec{"¯"}=42;
$spec{"°"}=43;
$spec{"±"}=44;
$spec{"»"}=45;
$spec{"¿"}=46;
$spec{"×"}=47;
$spec{"÷"}=48;
$spec{"%\^%"}=98;
$spec{"%\$%"}=99;
$spec{"_NUMBER_"}=100;





# read word lists

%wordnumber=();  # stores word nrs for strings
%freq=();  # stores frequencies
%multiword=();

foreach $key (keys %spec) {
  $wordnumber{$key}=$spec{$key};
  $freq{$key}=0;
}


$curr_nr=101;

open(WL,"<$ARGV[0]"); 
$maxparts=0;

while($in=<WL>) {
  chomp($in);
  @a=split(/\t/,$in);
  # print "defined: $in\n";
  $freq{$a[1]}=$a[0];

  if (defined $spec{$a[1]}) {$wordnumber{$a[1]}=$spec{$a[1]};}
  else {
    $wordnumber{$a[1]}=$curr_nr;
    $curr_nr++;
  }

  @mwp=split(/\s+/,$a[1]);
  if (@mwp>1) {$multiword{$a[1]}=1;}
  if (@mwp>=$maxparts) {$maxparts=@mwp;}
      
}
close(WL);

print "[index_wl] longest multiword length: $maxparts\n";


sub hashValueAscendingNum {
   $wordnumber{$a} <=> $wordnumber{$b};
}

open(TEXT,"<$ARGV[1]");

$line_nr=0;
while($inline=<TEXT>) {
  $line_nr++;

   if (($line_nr%$infostep) eq 0) {print "[index_wl] $ARGV[1] at line $line_nr\n";}


   chomp($inline);
   @a=split(/\t/,$inline);
   $snr=$a[0];
   $in="";
   for($pp=1;$pp<@a;$pp++) {$in=$in.$a[$pp];}

   @w=split(/\s+/,$in);
   
   
   # multi word units / singles
   $lock=0;
   $storedmultiword="";
   
   for($i=0;$i<=@w;$i++) {
     if ($lock>0) {$lock--;}
     if (0 == $lock && "" ne $storedmultiword){
      print INDEX $storedmultiword;
      $storedmultiword="";
     }
     for($len=$maxparts;$len>0;$len--) {
       if (($i+$len)<=@w) {
          $testword=$w[$i];
          for ($j=0;$j<$len;$j++) {
            if ($j eq 0) { $testword=$w[$i];} 
            else {$testword="$testword $w[$i+$j]";}
          } # rof
          #print "testing: '$testword'";          
            
          if (defined $multiword{$testword}) {
           #print "found: $testword\n";
           if ($lock eq 0) {
             $storedmultiword="$wordnumber{$testword}\t$snr\t$i\n";
             $lock=$len; 
           } else {
           # multiwords that overlap with current multiword are not indexed
           
             # print INDEX "$wordnumber{$testword}\t$snr\t$i\t-\n";
           }
          }
          
          if ($len eq 1) {
           # single words: substitute numbers
           if (($w[$i]=~m/[0-9]/)&&(!($w[$i]=~m/[A-Za-z]/))) {
             $singword="_NUMBER_";
           } else {
             $singword=$w[$i];
           }
          
          
           if ($lock eq 0) {
             print INDEX "$wordnumber{$singword}\t$snr\t$i\n";
           } else {
             print INDEX "$wordnumber{$singword}\t$snr\t$i\t-\n";
           }
          
          }
          
       } 
     
     }
   
   }
}

close(TEXT);

#$freq{"%\^%"}=$line_nr;
#$freq{"%\$%"}=$line_nr;




foreach $key (sort hashValueAscendingNum (keys %wordnumber)) {
  print WLNR "$wordnumber{$key}\t$key\t$freq{$key}\n";

}





exit();
