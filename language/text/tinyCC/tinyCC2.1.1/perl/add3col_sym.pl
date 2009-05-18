#!/usr/bin/perl -w

# unique3col takes tab-separated, sorted  3-col file and adds last column if first and second column are similar.
# clumns are written 2 times [1] [2] and [2] [1] for symmetry
# parameters:
#  - 3-col file w1, w2, number
# by Chris Biemann, Sep 2006
#
#
# usage
if (@ARGV ne 3) {die "Parameters (3): sorted_3colfile MINFREQ outname";}

open(IN,"<$ARGV[0]");
$MINFREQ=$ARGV[1];
if ($MINFREQ < 1) {$MINFREQ=1;}
open(OUT,">>$ARGV[2]");

$in=<IN>;
chomp($in);
@last=split(/\t/,$in);

while($in=<IN>) {
  chomp($in);
  @now=split(/\t/,$in);
  if (($now[0] eq $last[0])&&($now[1] eq $last[1])) {
    $last[2]=$last[2]+$now[2];
  } else {
    if ($last[2]>=$MINFREQ) {
     print OUT "$last[0]\t$last[1]\t$last[2]\n";
     print OUT "$last[1]\t$last[0]\t$last[2]\n";
    }
    $last[0]=$now[0];
    $last[1]=$now[1];
    $last[2]=$now[2];
  }
} # elihw
if ($last[2]>=$MINFREQ) {
 print OUT "$last[0]\t$last[1]\t$last[2]\n";
 print OUT "$last[1]\t$last[0]\t$last[2]\n";
}


close(IN);
close(OUT);