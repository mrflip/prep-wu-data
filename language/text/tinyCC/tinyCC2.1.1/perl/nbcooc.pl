#!/usr/bin/perl -w

# nbcooc_takes .index and calculates nb-cooccurrences
# parameters:
#  - word list: w_nr, word, freq
#  - index: w_nr, s_nr, pos, [-]
# by Chris Biemann, MAr 2006
#
# verbose
$infostep=100000;
#
# mem usage: top list size and max pairs
$topsize=5000;
$maxpairs=500000;
#
# usage
if (@ARGV ne 7) {die "Parameters (7): freq-wordlist tokenized-textfile max-mem(MB) MINFREQ MINSIG PREC outname\n given: @ARGV";}

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
  $nrToFreq{$a[0]}=$a[2];
  if ($a[0]>$maxnr) {$maxnr=$a[0];}
} # elihw

if ($maxnr < $topsize) {$topsize=$maxnr;}
$paircount=0;

print "[nbcooc] using top frequency array of size $topsize x $topsize, buffer of $maxpairs\n";

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

print "[nbcooc] array initialized\n";

open(INDEX,"<$ARGV[1]"); 

$oldsnr=-1;
$lastwnr=-1;
$lastplus=-1;
$lastsign="+";
$multiflag=0;
$stepcount=0;

open(NBFREQTEMP,">$ARGV[1].nbfreqtemp");

%neigh=();

$linenr=0;
while($in=<INDEX>) {

  $linenr=$linenr+1;
  if (($linenr % $infostep) == 0) 
    {print "[nbcooc] file $ARGV[1] at line $linenr \n";}

  chomp($in);
  @a=split(/\t/,$in);
 
  if (@a eq 3) {$a[3]="+";}
  if ($oldsnr ne $a[1]) { # sentence change
    $oldsnr=$a[1];
    $lastminus=-1;
    $lastplus=-1;
    $lastsign="+";
  } else { # neighbours within sentence
    
    if (($a[3] eq "+")&&($lastsign eq "-")) {  # multiterm
      if ($lastplus>=0) {
        $insert="$lastplus\t$a[0]";
      } else {
        $insert="";
      }
      $multiflag=1;
      $insert2="";
      $lastminus=$lastwnr;
    } elsif (($multiflag eq 1)&&($lastsign eq "+")) { # one past multiterm
     $insert2="$lastminus\t$a[0]";
       $insert="$lastwnr\t$a[0]";
    # $multiflag=0;
    } else { # 'normal' neighbours
      $insert="$lastwnr\t$a[0]";
    }

    if($insert ne "") {
      @d=split(/\t/,$insert);
      
      # both in top-array
      if (($d[0]<$topsize)&&($d[1]<$topsize)) {
           $topcooc[$d[0]*$topsize+$d[1]]++;  

      } else { # not in topsize
        if (defined $neigh{$insert}) {
          $neigh{$insert}=$neigh{$insert}+1;
        } else {
          $neigh{$insert}=1;
	    $currpaircount++;
        }
	} #esle topsite
     $paircount++;
    } # fi insert ne ""


    # solves minus and word after multiterm
    if (($multiflag eq 1)&&($insert2 ne "")) {
      @d=split(/\t/,$insert2);
      
      # both in top-array
      if (($d[0]<$topsize)&&($d[1]<$topsize)) {
           $topcooc[$d[0]*$topsize+$d[1]]++;  

      } else { # not in topsize
        if (defined $neigh{$insert2}) {
          $neigh{$insert2}=$neigh{$insert2}+1;
        } else {
          $neigh{$insert2}=1;
	    $currpaircount++;
        }

      } # esle topsize

     
     $multiflag=0;
#     print "  Inserting2: $insert2\n";
     # since multiterms do not count and one multi-pair is already there:
     $paircount--;

    } # fi multi insert2


  } # esle fi sentence change
  
  $lastsign=$a[3];
  $lastwnr=$a[0];
  if ($a[3] eq "+") {$lastplus=$a[0];}

  # flush buffer
  if ($currpaircount > $maxpairs) {
     foreach $key (keys %neigh) {
        print NBFREQTEMP "$key\t$neigh{$key}\n";
     }    
     $currpaircount=0;
     $stepcount++;
     %neigh=();  # dispose
  } # fi currpaircount
      
}
close(INDEX);

# flush rest
foreach $key (keys %neigh) {
  print NBFREQTEMP "$key\t$neigh{$key}\n";
}    
$currpaircount=0;
%neigh=(); # dispose

$display=$stepcount+1;
print "[nbcooc] wrote $display chunk(s)\n";

close(NBFREQTEMP);


print "[nbcooc] Number of pairs: $paircount\n";

open(NBFREQ,">$ARGV[1].nbfreq");

#write top-matrix
for($i=1;$i<$topsize;$i++) {
  for($j=1;$j<$topsize;$j++) {
     if ($topcooc[$i*$topsize+$j]>=$MINFREQ) {
       print NBFREQ "$i\t$j\t$topcooc[$i*$topsize+$j]\n";
     } # fi >0
  } # rof j
} # rof i

@topcooc=(); # dispose


if ($stepcount eq 0) {  
   # counts in NBFREQTEMP are unique-correct since all fit in memory: append it to NBFREQ
   open(NBFREQTEMP,"<$ARGV[1].nbfreqtemp");
   while($in=<NBFREQTEMP>) {
     chomp($in);
     @d=split(/\t/,$in);
     if ($d[2]>=$MINFREQ) {
       print NBFREQ "$d[0]\t$d[1]\t$d[2]\n";
     } # fi minfreq
   }
   close(NBFREQTEMP);
} else {
  # scan it for several times. We needed $stepcount steps before
  # , so we do (for safety) $stepcount+1 steps now by only adding wnr_1s % steps = [0..steps]

  $modmod=$stepcount+1;
  for($it=0;$it<$modmod;$it++) {
   $step=$it+1;
   print "[nbcooc] adding co-occurrence frequencies step $step of $modmod\n";

   open(NBFREQTEMP,"<$ARGV[1].nbfreqtemp");
   %modpairs=();

   while($in=<NBFREQTEMP>) {
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
   close(NBFREQTEMP);

   foreach $key (keys %modpairs) {
     @d=split(/\t/,$key);
     if ($modpairs{$key}>=$MINFREQ) {
       print NBFREQ "$d[0]\t$d[1]\t$modpairs{$key}\n";
     } # fi minfreq
   } # hcaerof 

  } # rof it
} # esle stepcount >0


close(NBFREQ);
%neigh=(); # dispose


# scan NBFREQ and add sig_val

open(NBCOOC,">$OUTFILE");
open(NBFREQ,"<$ARGV[1].nbfreq");

# formula: log-likelihood: 
# ll= ?2 log lambda = 2 * [ n log n ? nA log nA ? nB log nB + nAB log nAB
#		      +(n ? nA ? nB + nAB) log (n ? nA ? nB + nAB)
#		      +(nA ? nAB) log (nA ? nAB) + (nB ? nAB) log (nB ? nAB)
#		      ?(n ? nA) log (n ? nA) ? (n ? nB) log (n ? nB) ]

$n=$paircount;


$nonzero=0.0000000000001; # for nonzero-logarithms. As we find integers within log, this does not significantly change results

$linenr=0;
while($in=<NBFREQ>) {
  $linenr=$linenr+1;
  if (($linenr % $infostep) == 0) 
    {print "[nbcooc] file $ARGV[1].nbfreq at line $linenr \n";}

   chomp($in);
   @a=split(/\t/,$in);   
   $nA=$nrToFreq{$a[0]};
   $nB=$nrToFreq{$a[1]};
   $nAB=$a[2];
   

   # print "n=$n nA=$nA nB=$nB nAB=$nAB at $in\n";

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
       print NBCOOC "$in\t$ll\n";
   }
                                
}

close(NBCOOC);

exit;

