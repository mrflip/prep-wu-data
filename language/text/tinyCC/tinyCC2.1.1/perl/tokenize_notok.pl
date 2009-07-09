#!/usr/bin/perl -w

# tokenize.pl: Tokenizer 
# by Chris Biemann, Feb 2006
#   THIS IS A NON-TOKENIZER FOR PRETOKENIZED TEXT

# the tokenizer adds spaces so that "words" are seperated by single spaces. 
# note that it does not deal with abbreiviations, so "Dr. Best sleeps!" goes to "Dr . Best sleeps !"
# "words" are also special characters like interpunctuation marks, brackets etc.
#
# special chars will be seperated if they are neighboured by a blank. so "3-4,5-di(hydrid)ethan" remains one word.
# exception: The apostroph ' is a single word. so, "aujourd'hui" -> "aujourd ' hui"
# 
# The tokenizer is tuned for ASCII-Text of natural language.
#
#
# line numbers separated by tab are preserved.
#
#
# verbose: info step 
$info_step=10000;
#
#
# usage
if (@ARGV ne 2) {die "Parameters (2): one-sentence-per-line textfile, tokenized_textfile";}

open(FILE,"<$ARGV[0]") or die "Cannot find $ARGV[0]\n";
open(OUT, ">$ARGV[1]");

$linenr=0;

while($in=<FILE>) {
  chomp($in);

  $linenr=$linenr+1;
  if (($linenr % $info_step) == 0) 
    {print "[tokenize] file $ARGV[0] at line $linenr \n";}

  @a=split(/\t/,$in);
  if (($a[0]=~m/[0-9]/)&&(!($a[0]=~m/[A-Za-z]/))) {
    print OUT "$a[0]\t";
    $in="";
    for($pp=1;$pp<@a;$pp++) {$in=$in.$a[$pp];}
  }


  $in=" $in ";

# special chars:

# do this for some cycles to solve augmented things like ",,what?''"

for($it=0;$it<0;$it++) {
  $in=~s/\"/ \" /g;
  $in=~s/, / , /g;
  $in=~s/: / : /g;
  $in=~s/; / ; /g;
  $in=~s/\) / \) /g;
  $in=~s/! / ! /g;
  $in=~s/\? / \? /g;
  $in=~s/\( / \( /g;  
  $in=~s/¡ / ¡ /g;
  $in=~s/¿ / ¿ /g;
  $in=~s/'/ ' /g;
  $in=~s/& / & /g;
  $in=~s/\* / * /g;
  $in=~s/\/ / \/ /g;
  $in=~s/\\ / \\ /g;
  $in=~s/\. / . /g;
  $in=~s/\# / \# /g;
  $in=~s/\$ / \$ /g;
  $in=~s/% / % /g;
  $in=~s/\+ / + /g;
  $in=~s/< / < /g;
  $in=~s/> / > /g;
  $in=~s/= / = /g;
  $in=~s/\[ / [ /g;  
  $in=~s/\] / ] /g;
  $in=~s/\^ / ^ /g;
  $in=~s/} / } /g;
  $in=~s/{ / { /g;
  $in=~s/\| / | /g;
  $in=~s/` / ` /g;
  $in=~s/« / « /g;
  $in=~s/» / » /g;
  $in=~s/¤ / ¤ /g;

  $in=~s/ \"/ \" /g;
  $in=~s/ ,/ , /g;
  $in=~s/ :/ : /g;
  $in=~s/ ;/ ; /g;
  $in=~s/ \)/ \) /g;
  $in=~s/ !/ ! /g;
  $in=~s/ \?/ \? /g;
  $in=~s/ \(/ \( /g;
  $in=~s/ ¡/ ¡ /g;
  $in=~s/ ¿/ ¿ /g;
  $in=~s/'/ ' /g;
  $in=~s/ &/ & /g;
  $in=~s/ \*/ * /g;
  $in=~s/ \// \/ /g;
  $in=~s/ \\/ \\ /g;
  $in=~s/ \./ . /g;

  $in=~s/ \#/ \# /g;
  $in=~s/ \$/ \$ /g;
  $in=~s/ %/ % /g;
  $in=~s/ \+/ + /g;
  $in=~s/ </ < /g;
  $in=~s/ >/ > /g;
  $in=~s/ =/ = /g;
  $in=~s/ \[/ [ /g;
  $in=~s/ \]/ ] /g;
  $in=~s/ \^/ ^ /g;
  $in=~s/ }/ } /g;
  $in=~s/ {/ { /g;
  $in=~s/ \|/ | /g;
  $in=~s/ /  /g;
  $in=~s/ «/ « /g;
  $in=~s/ »/ » /g;
  $in=~s/ ¤/ ¤ /g;



} 


  # out
  $outline="";
  @w=split(/\s+/,$in);
  for($i=0;$i<@w;$i++) {
    $outline=$outline." ".$w[$i];
  }
  
  if (length($outline)>=2) {$outline=substr($outline,2,length($outline));}
  
  print OUT "%\^% $outline %\$%\n";


} # elihw

close(FILE);

close(OUT);

exit;


# DEMO:

# Input:
# -------
# ¿Cuál fue la mejor decada musical?
# I simply can't owe you 30-40,000 bucks!


# Gerhard Schröder (SPD), der 61jährige Ex-Kanzler, meint: "Es ist vielleicht eine Große Chance!"
#  Ihr Hotel an der Scater- und Fahrradstreckestrecke in J&uuml;terbog mit 3,4-dihydrit(bi)methen.
#     Videre er det opprettet samarbeid med Logon on å kunne bruke grammatikken fra NorGram og XLE (http://www.ling.uib.no/~victoria/NorGram/).  
#
# OUTPUT
# -------
# ¿ Cuál fue la mejor decada musical ?
# I simply can't owe you _NUMBER_ bucks !


# Gerhard Schröder ( SPD ) , der 61jährige Ex-Kanzler , meint : " Es ist vielleicht eine Große Chance ! "
# Ihr Hotel an der Scater- und Fahrradstreckestrecke in J&uuml;terbog mit 3,4-dihydrit(bi)methen .
# Videre er det opprettet samarbeid med Logon on å kunne bruke grammatikken fra NorGram og XLE ( http://www.ling.uib.no/~victoria/NorGram/) .
#
