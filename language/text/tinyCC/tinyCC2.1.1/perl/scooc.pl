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
if (@ARGV ne 7) {die "Parameters (7): freq-wordlist index max-mem(MB) MINFREQ MINSIG PREC outname";}

if (!($ARGV[2] > 0)) {$ARGV[2]=128;}

$topsize=int($ARGV[2]*5);
$maxpairs=int($ARGV[2]*4000);

$MINFREQ=$ARGV[3];
$MINSIG=$ARGV[4];
$PREC=10**$ARGV[5];
$OUTFILE=$ARGV[6];

if ($topsize<1000) {$topsize=1000;}
if ($maxpairs<10000) {$maxpairs=10000;}


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


open(SFREQTEMP,">$ARGV[1].sfreqtemp");

$linenr=0;

$sentence_count=0;

while($in=<INDEX>) {

  $linenr=$linenr+1;
  if (($linenr % $infostep) == 0) 
    {print "[scooc] file $ARGV[1] at line $linenr \n";}

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
       
       if(($nrToCorpusFreq{$lower}>=$MINFREQ)&&($nrToCorpusFreq{$higher}>=$MINFREQ)) { 
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
     } # fi both corpus freq >= MINFREQ 
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


print "[scooc] Number of pairs: $paircount for $sentence_count sentences\n";

#write top-matrix

open(OUTFREQ,">$ARGV[1].scoocfreq");

for($i=1;$i<$topsize;$i++) {
  for($j=$i+1;$j<$topsize;$j++) {
     if ($topcooc[$i*$topsize+$j]>=$MINFREQ) {
       print OUTFREQ "$i\t$j\t$topcooc[$i*$topsize+$j]\n";
       print OUTFREQ "$j\t$i\t$topcooc[$i*$topsize+$j]\n";
     } # fi >0
  } # rof j
} # rof i

@topcooc=(); # dispose


if ($stepcount eq 0) {  
   # counts in SFREQTEMP are unique-correct since all fit in memory: append it to OUTFREQ
   open(SFREQTEMP,"<$ARGV[1].sfreqtemp");
   while($in=<SFREQTEMP>) {
     chomp($in);
     @d=split(/\t/,$in);
     if ($d[2]>=$MINFREQ) {
      print OUTFREQ "$d[0]\t$d[1]\t$d[2]\n";
      print OUTFREQ "$d[1]\t$d[0]\t$d[2]\n";
     } # fi MINFREQ
   }
   close(SFREQTEMP);
} else {
  # scan it for several times. We needed $stepcount steps before
  # , so we do (for safety) $stepcount+1 steps now by only adding wnr_1s % steps = [0..steps]

  $modmod=$stepcount+1;
  for($it=0;$it<$modmod;$it++) {
   $step=$it+1;
   print "[scooc] adding co-occurrence frequencies step $step of $modmod\n";

   open(SFREQTEMP,"<$ARGV[1].sfreqtemp");
   %modpairs=();

   while($in=<SFREQTEMP>) {
     chomp($in);
     @a=split(/\t/,$in);
     if (($a[0] % $modmod) eq $it) {
        $insert="$a[0]\t$a[1]";
        if (defined $modpairs{$insert}) {
       	$modpairs{$insert}=$modpairs{$insert}+$a[2];
  	  } else {
       	$modpairs{$insert}=$a[2];
	  } # esle fi
     } # fi
   } # elihw
   close(SFREQTEMP);

   foreach $key (keys %modpairs) {
     @d=split(/\t/,$key);
     if($modpairs{$key}>=$MINFREQ) {
      print OUTFREQ "$d[0]\t$d[1]\t$modpairs{$key}\n";
      print OUTFREQ "$d[1]\t$d[0]\t$modpairs{$key}\n";
     } # fi MINFREQ 
   } # hcaerof 

  } # rof it
} # esle stepcount >0


close(OUTFREQ);  
 

# scan OUTFREQ and add sig_val

open(SCOOC,">$OUTFILE");
open(OUTFREQ,"<$ARGV[1].scoocfreq");

# formula: log-likelihood: 
# ll= -2 log lambda = 2 * [ n log n - nA log nA - nB log nB + nAB log nAB
#		      +(n - nA - nB + nAB) log (n - nA - nB + nAB)
#		      +(nA - nAB) log (nA - nAB) + (nB - nAB) log (nB - nAB)
#		      -(n - nA) log (n - nA) - (n - nB) log (n - nB) ]
#
#  n : count of possible pairs
#  nA: count of A
#  nB count of B
#  nAB: count of joint occurrence A and B



$n=$sentence_count;


$nonzero=0.0000000000001;
while($in=<OUTFREQ>) {
   chomp($in);
   @a=split(/\t/,$in);   
   $nA=$nrToFreq{$a[0]};
   $nB=$nrToFreq{$a[1]};
   $nAB=$a[2];
   

#   print SCOOC "n=$n nA=$nA nB=$nB nAB=$nAB at $in\n";

   $surprise= 2*($n*log($n)-$nA*log($nA)-$nB*log($nB)+$nAB*log($nAB)
        +($n-$nA-$nB+$nAB)*log($n-$nA-$nB+$nAB+$nonzero)
        +($nA-$nAB)*log($nA-$nAB+$nonzero)+($nB-$nAB)*log($nB-$nAB+$nonzero)
        -($n-$nA)*log($n-$nA+$nonzero)-($n-$nB)*log($n-$nB+$nonzero) );

   # negative or positive correlation
   if (($n * $nAB) < ($nA * $nB)) 
      { $ll=$surprise*(-1); }
   else {$ll=$surprise;}   
   
   # round
   $ll=int($ll*$PREC+0.5)/$PREC;
   
   if ($ll>=$MINSIG) {
     print SCOOC "$in\t$ll\n";
   }  
}


exit;

