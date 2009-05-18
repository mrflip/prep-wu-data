#!/usr/bin/perl -w

# scooc takes .index and calculates sentence-based coocs
# parameters:
#  - word list: w_nr, word, freq
#  - index: w_nr, s_nr, pos, [-]
# by Chris Biemann, MAr 2006
#
# verbose
$infostep=100000;
#
#
# mem usage: top list size and max pairs
$topsize=5000;
$maxpairs=500000;
#
# usage
if (@ARGV ne 5) {die "Parameters (5): freq-wordlist index max-mem(MB) MINFREQ outname";}

if (!($ARGV[2] > 0)) {$ARGV[2]=1;}

$topsize=int($ARGV[2]*5);
$maxpairs=int($ARGV[2]*4000);

$MINFREQ=$ARGV[3];
$OUTFILE=$ARGV[4];

if ($topsize<1000) {$topsize=1000;}
if ($maxpairs<10000) {$maxpairs=10000;}

sub hashValueDescendingNum {
   $a <=> $b;  
}
   

# read in frequencies
open(WL,"<$ARGV[0]");

$maxnr=0;

%nrToFreq=();
while($in=<WL>) {
  chomp($in);
  @a=split(/\t/,$in);
  $nrToFreq{$a[0]}=0;            # unique counts for sentences
  $nrToCorpusFreq{$a[0]}=$a[2];  # real counts for optimization
  if ($a[0]>$maxnr) {$maxnr=$a[0];}
} # elihw


if ($maxnr < $topsize) {$topsize=$maxnr;}

print "[scooc] using top frequency array of size $topsize x $topsize, buffer of $maxpairs\n";

# we assume frequency-sorted word list: the smallest numbers have the hightst frequencies.
# these will have the highest number of co-occurrences and are stored in an array.
@topcooc=();

for($i=0;$i<$topsize;$i++) {
  for($j=0;$j<$topsize;$j++) {
     $topcooc[$i*$topsize+$j]=0;	
  } # rof j
} # rof i

$paircount=0;  # for counting all pairs
$currpaircount=0;  # for counting how many pairs we keep in mem

print "[scooc] array initialized\n";

open(INDEX,"<$ARGV[1]"); 

$oldsnr=-1;
$words=();
$pos=0;
%senhash=();	 
%currpairs=();
$stepcount=0;


open(SFREQTEMP,">$OUTFILE.sfreqtemp");

$linenr=0;

$sentence_count=0;

while($in=<INDEX>) {

  $linenr=$linenr+1;
  if (($linenr % $infostep) == 0) 
    {print "[sfreq] file $ARGV[1] at line $linenr \n";}

  chomp($in);

  #print "$in\n";

  @a=split(/\t/,$in);
 
  if ($oldsnr ne $a[1]) { # sentence change
    # convert hash to array
    @words=();
    $pos=0;
    foreach $key (keys %senhash) {
      $words[$pos]=$key;
      $pos++;
      $nrToFreq{$key}++;
    } # hcaerof

    %senhash=();	 
    # process array
    for($i=0;$i<$pos;$i++) {
      for($j=$i+1;$j<$pos;$j++) {
       if ($words[$i]<$words[$j]) {$lower=$words[$i];$higher=$words[$j];}
       else {$lower=$words[$j];$higher=$words[$i];}


       $paircount++;
       
       if(($nrToCorpusFreq{$lower}>=1)&&($nrToCorpusFreq{$higher}>=1)) { 
        # both in toplist
        if (($lower<$topsize)&&($higher<$topsize)) {
           $topcooc[$lower*$topsize+$higher]++;  

		# print "  inserting in top-array: $lower - $higher\n";
	  } 
        # not both in toplist
        else {
		$insert="$lower\t$higher";
		# print "  inserting in hash: $lower - $higher\n";
     		if (defined $currpairs{$insert}) {
       		$currpairs{$insert}=$currpairs{$insert}+1;

     		} else {
       		$currpairs{$insert}=1;
		      $currpaircount++;
     		} # esle fi
	  } # esle not in toplist
      } # rof j
     } # fi both corpus freq >= 1
    } # rof i

    # reset
    $oldsnr=$a[1];
    $senhash{$a[0]}=1;   
    $sentence_count++;
  
  } else { #build new sentence
    $senhash{$a[0]}=1;
  } # esle new sentence
    
  
  # flush memory
  if ($currpaircount > $maxpairs) {
     foreach $key (keys %currpairs) {
        print SFREQTEMP "$key\t$currpairs{$key}\n";
     }    
     $currpaircount=0;
     $stepcount++;
     %currpairs=();  # dispose
  } # fi currpaircount
} # elihw
close(INDEX);

# last sentence:
# (COPY FROM ABOVE)

    # convert hash to array
    @words=();
    $pos=0;
    foreach $key (keys %senhash) {
      $words[$pos]=$key;
      $pos++;
      $nrToFreq{$key}++;
    } # hcaerof

    %senhash=();	 
    # process array
    for($i=0;$i<$pos;$i++) {
      for($j=$i+1;$j<$pos;$j++) {
        if ($words[$i]<$words[$j]) {$lower=$words[$i];$higher=$words[$j];}
        else {$lower=$words[$j];$higher=$words[$i];}


	  $paircount++;
        
        # both in toplist
        if (($lower<$topsize)&&($higher<$topsize)) {
           $topcooc[$lower*$topsize+$higher]++;  

		# print "  inserting in top-array: $lower - $higher\n";
	  } 
        # not both in toplist
        else {
		$insert="$lower\t$higher";
     		if (defined $currpairs{$insert}) {
       		$currpairs{$insert}=$currpairs{$insert}+1;

	            #print "  inserting in hash: $lower - $higher\n";

     		} else {
       		$currpairs{$insert}=1;
		      $currpaircount++;
     		} # esle fi
	  } # esle not in toplist
      } # rof j
    } # rof i


# flush rest
foreach $key (keys %currpairs) {
  print SFREQTEMP "$key\t$currpairs{$key}\n";
}    
$currpaircount=0;
%currpairs=(); # dispose

$display=$stepcount+1;
print "[scooc] wrote $display chunk(s)\n";

close(SFREQTEMP);


# write nr of experiments to scount
open(SCOUNT,">$ARGV[1].scount");
print SCOUNT "$sentence_count\n";
close(SCOUNT);
print "[scooc] Number of pairs: $paircount for $sentence_count sentences\n";

# write unique counts in 2col file 
open(UNIQWL,">$ARGV[0].unique");
foreach $key (sort hashValueDescendingNum keys %nrToFreq) {
 if (defined $nrToFreq{$key}) {
  print UNIQWL "$key\t$nrToFreq{$key}\n";
 } #fi 
} #hearof
close (UNIQWL);


#write top-matrix
open(OUTFREQ,">$OUTFILE.sfreq");

for($i=1;$i<$topsize;$i++) {
  for($j=$i+1;$j<$topsize;$j++) {
     if ($topcooc[$i*$topsize+$j]>=$MINFREQ) {
       print OUTFREQ "$i\t$j\t$topcooc[$i*$topsize+$j]\n";
       print OUTFREQ "$j\t$i\t$topcooc[$i*$topsize+$j]\n";
     } # fi >0
  } # rof j
} # rof i

