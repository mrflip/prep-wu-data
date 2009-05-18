#!/usr/bin/perl -w

# tok_multiwords.pl: Tokenizer 
# by Chris Biemann, Mar 2006
#

# the tokenizer tokenizes multiwods in order to match thwem to the tokenized text so that "words" are seperated by single spaces. 
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

  if (($linenr % $info_step) == 0) 
    {print "[tokenize] file $ARGV[0] at line $linenr \n";}
   $linenr=$linenr+1;

  @a=split(/\t/,$in);
  if (($a[0]=~m/[0-9]/)&&(!($a[0]=~m/[A-Za-z]/))) {
    print OUT "$a[0]\t";
    $in="";
    for($pp=1;$pp<@a;$pp++) {$in=$in.$a[$pp];}
  }


  $in=" $in ";

# special chars:

# do this for some cycles to solve augmented things like ",,what?''"

for($it=0;$it<3;$it++) {
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
  $in=~s/۔ / ۔ /g;
  $in=~s/\# / \# /g;
  $in=~s/\$ / \$ /g;
#  $in=~s/% / % /g;
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
  $in=~s/® / ® /g;
  $in=~s/™ / ™ /g;
  $in=~s/¤ / ¤ /g;
  $in=~s/€ / € /g;
  $in=~s/£ / £ /g;
  $in=~s/¥ / ¥ /g;
  $in=~s/￥ / ￥ /g;
  $in=~s/‹ / ‹ /g;
  $in=~s/› / › /g;
  $in=~s/“ / “ /g;
  $in=~s/” / ” /g;
  $in=~s/„ / „ /g;
  $in=~s/‚ / ‚ /g;
  $in=~s/‘ / ‘ /g;
  $in=~s/’ / ’ /g;
  $in=~s/「 / 「 /g;
  $in=~s/」 / 」 /g;
  $in=~s/『 / 『 /g;
  $in=~s/』 / 』 /g;
  $in=~s/〈 / 〈 /g;
  $in=~s/〉 / 〉 /g;
  $in=~s/《 / 《 /g;
  $in=~s/》 / 》 /g;
  $in=~s/₩ / ₩ /g;
  $in=~s/¢ / ¢ /g;
  $in=~s/฿ / ฿ /g;
  $in=~s/₫ / ₫ /g;
  $in=~s/₤ / ₤ /g;
  $in=~s/₦ / ₦ /g;
  $in=~s/元 / 元 /g;
  $in=~s/₪ / ₪ /g;
  $in=~s/₱ / ₱ /g;
  $in=~s/₨ / ₨ /g;

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
  $in=~s/ ۔ /۔ /g;

  $in=~s/ \#/ \# /g;
  $in=~s/ \$/ \$ /g;
#  $in=~s/ %/ % /g;
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
  $in=~s/ ®/ ® /g;
  $in=~s/ ™/ ™ /g;
  $in=~s/ ¤/ ¤ /g;
  $in=~s/ €/ € /g;
  $in=~s/ £/ £ /g;
  $in=~s/ ¥/ ¥ /g;
  $in=~s/ ￥/ ￥ /g;
  $in=~s/ ‹/ ‹ /g;
  $in=~s/ ›/ › /g;
  $in=~s/ “/ “ /g;
  $in=~s/ ”/ ” /g;
  $in=~s/ „/ „ /g;
  $in=~s/ ‚/ ‚ /g;
  $in=~s/ ‘/ ‘ /g;
  $in=~s/ ’/ ’ /g;
  $in=~s/ 「/ 「 /g;
  $in=~s/ 」/ 」 /g;
  $in=~s/ 『/ 『 /g;
  $in=~s/ 』/ 』 /g;
  $in=~s/ 〈/ 〈 /g;
  $in=~s/ 〉/ 〉 /g;
  $in=~s/ 《/ 《 /g;
  $in=~s/ 》/ 》 /g;
  $in=~s/ ₩/ ₩ /g;
  $in=~s/ ¢/ ¢ /g;
  $in=~s/ ฿/ ฿ /g;
  $in=~s/ ₫/ ₫ /g;
  $in=~s/ ₤/ ₤ /g;
  $in=~s/ ₦/ ₦ /g;
  $in=~s/ 元/ 元 /g;
  $in=~s/ ₪/ ₪ /g;
  $in=~s/ ₱/ ₱ /g;
  $in=~s/ ₨/ ₨ /g;

} 


  # out
  $outline="";
  @w=split(/\s+/,$in);
  for($i=0;$i<@w;$i++) {
    $outline=$outline." ".$w[$i];
  }
  
  if (length($outline)>=2) {$outline=substr($outline,2,length($outline));}
  
  print OUT "$outline\n";


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
