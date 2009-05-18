#!/usr/bin/perl -w

# detok_multiwords.pl: Tokenizer 
# by Chris Biemann, Mar 2006
#
# this script transforms the word list built with tokenized multiwords back to
# 'untokenized' word list formst, i.E. strips superfluous spaces.
# verbose: info step 
$info_step=100000;
#
#
# usage
if (@ARGV ne 2) {die "Parameters (2): tokenized_wordlist out:detok.wordlist";}

open(FILE,"<$ARGV[0]") or die "Cannot find $ARGV[0]\n";
open(OUT, ">$ARGV[1]");

$linenr=0;

while($in=<FILE>) {
  chomp($in);

   $linenr=$linenr+1;

  if (($linenr % $info_step) == 0) 
    {print "[detok] file $ARGV[0] at line $linenr \n";}

  @f=split(/\t/,$in);
  $word=$f[1];
  @a=split(/\s/,$word);
  
  if (@a eq 1) {  # single words: stay the same
    # noop
  } else {
  $word=~s/\"/ \" /g;
  $word=~s/, / , /g;
  $word=~s/: / : /g;
  $word=~s/; / ; /g;
  $word=~s/\) / \) /g;
  $word=~s/! / ! /g;
  $word=~s/\? / \? /g;
  $word=~s/\( / \( /g;  
  $word=~s/¡ / ¡ /g;
  $word=~s/¿ / ¿ /g;
  $word=~s/'/ ' /g;
  $word=~s/& / & /g;
  $word=~s/\* / * /g;
  $word=~s/\/ / \/ /g;
  $word=~s/\\ / \\ /g;
  $word=~s/\. / . /g;
  $word=~s/۔ / ۔ /g;
  $word=~s/\# / \# /g;
  $word=~s/\$ / \$ /g;
#  $word=~s/% / % /g;
  $word=~s/\+ / + /g;
  $word=~s/< / < /g;
  $word=~s/> / > /g;
  $word=~s/= / = /g;
  $word=~s/\[ / [ /g;  
  $word=~s/\] / ] /g;
  $word=~s/\^ / ^ /g;
  $word=~s/} / } /g;
  $word=~s/{ / { /g;
  $word=~s/\| / | /g;
  $word=~s/` / ` /g;
  $word=~s/« / « /g;
  $word=~s/» / » /g;
  $word=~s/® / ® /g;
  $word=~s/™ / ™ /g;
  $word=~s/¤ / ¤ /g;
  $word=~s/€ / € /g;
  $word=~s/£ / £ /g;
  $word=~s/¥ / ¥ /g;
  $word=~s/￥ / ￥ /g;
  $word=~s/‹ / ‹ /g;
  $word=~s/› / › /g;
  $word=~s/“ / “ /g;
  $word=~s/” / ” /g;
  $word=~s/„ / „ /g;
  $word=~s/‚ / ‚ /g;
  $word=~s/‘ / ‘ /g;
  $word=~s/’ / ’ /g;
  $word=~s/「 / 「 /g;
  $word=~s/」 / 」 /g;
  $word=~s/『 / 『 /g;
  $word=~s/』 / 』 /g;
  $word=~s/〈 / 〈 /g;
  $word=~s/〉 / 〉 /g;
  $word=~s/《 / 《 /g;
  $word=~s/》 / 》 /g;
  $word=~s/₩ / ₩ /g;
  $word=~s/¢ / ¢ /g;
  $word=~s/฿ / ฿ /g;
  $word=~s/₫ / ₫ /g;
  $word=~s/₤ / ₤ /g;
  $word=~s/₦ / ₦ /g;
  $word=~s/元 / 元 /g;
  $word=~s/₪ / ₪ /g;
  $word=~s/₱ / ₱ /g;
  $word=~s/₨ / ₨ /g;

  $word=~s/ \"/ \" /g;
  $word=~s/ ,/ , /g;
  $word=~s/ :/ : /g;
  $word=~s/ ;/ ; /g;
  $word=~s/ \)/ \) /g;
  $word=~s/ !/ ! /g;
  $word=~s/ \?/ \? /g;
  $word=~s/ \(/ \( /g;
  $word=~s/ ¡/ ¡ /g;
  $word=~s/ ¿/ ¿ /g;
  $word=~s/'/ ' /g;
  $word=~s/ &/ & /g;
  $word=~s/ \*/ * /g;
  $word=~s/ \// \/ /g;
  $word=~s/ \\/ \\ /g;
  $word=~s/ \./ . /g;
  $in=~s/ ۔ /۔ /g;

  $word=~s/ \#/ \# /g;
  $word=~s/ \$/ \$ /g;
#  $word=~s/ %/ % /g;
  $word=~s/ \+/ + /g;
  $word=~s/ </ < /g;
  $word=~s/ >/ > /g;
  $word=~s/ =/ = /g;
  $word=~s/ \[/ [ /g;
  $word=~s/ \]/ ] /g;
  $word=~s/ \^/ ^ /g;
  $word=~s/ }/ } /g;
  $word=~s/ {/ { /g;
  $word=~s/ \|/ | /g;
  $word=~s/ /  /g;
  $word=~s/ «/ « /g;
  $word=~s/ »/ » /g;
  $word=~s/ ®/ ® /g;
  $word=~s/ ™/ ™ /g;
  $word=~s/ ¤/ ¤ /g;
  $word=~s/ €/ € /g;
  $word=~s/ £/ £ /g;
  $word=~s/ ¥/ ¥ /g;
  $word=~s/ ￥/ ￥ /g;
  $word=~s/ ‹/ ‹ /g;
  $word=~s/ ›/ › /g;
  $word=~s/ “/ “ /g;
  $word=~s/ ”/ ” /g;
  $word=~s/ „/ „ /g;
  $word=~s/ ‚/ ‚ /g;
  $word=~s/ ‘/ ‘ /g;
  $word=~s/ ’/ ’ /g;
  $word=~s/ 「/ 「 /g;
  $word=~s/ 」/ 」 /g;
  $word=~s/ 『/ 『 /g;
  $word=~s/ 』/ 』 /g;
  $word=~s/ 〈/ 〈 /g;
  $word=~s/ 〉/ 〉 /g;
  $word=~s/ 《/ 《 /g;
  $word=~s/ 》/ 》 /g;
  $word=~s/ ₩/ ₩ /g;
  $word=~s/ ¢/ ¢ /g;
  $word=~s/ ฿/ ฿ /g;
  $word=~s/ ₫/ ₫ /g;
  $word=~s/ ₤/ ₤ /g;
  $word=~s/ ₦/ ₦ /g;
  $word=~s/ 元/ 元 /g;
  $word=~s/ ₪/ ₪ /g;
  $word=~s/ ₱/ ₱ /g;
  $word=~s/ ₨/ ₨ /g;
  
 ##    print "$word->";
#    $word=~s/ \" /\"/g;
#    $word=~s/ \' /\'/g;
#    $word=~s/ \././g;
#    $word=~s/ & /& /g;            
#    $word=~s/ ,/,/g; 
#    $word=~s/ \)/)/g;
#    $word=~s/\( /(/g;
#    $word=~s/ \]/]/g;
#    $word=~s/\[ /[/g;
#
#    $word=~s/ `/`/g;
#    $word=~s/ «/«/g;
#    $word=~s/» /»/g;
#    $word=~s/ ¤/¤/g;
#    $word=~s/ :/:/g;
#    $word=~s/ ;/;/g;
#    $word=~s/ !/!/g;
#  $word=~s/ \?/\?/g;
#  $word=~s/ ¡/¡/g;
#  $word=~s/ ¿/¿/g;
#  $word=~s/ &/ &/g;
#  $word=~s/ \*/*/g;
#  $word=~s/ \//\//g;
#  $word=~s/ \\/\\/g;
#
#  $word=~s/ \#/\#/g;
#  $word=~s/ \$/\$/g;
#  $word=~s/ \+/+/g;
#  $word=~s/ </</g;
#  $word=~s/ >/>/g;
#  $word=~s/ =/=/g;
#  $word=~s/ \^/^/g;
#  $word=~s/ }/}/g;
#  $word=~s/{ /{/g;
#  $word=~s/ \|/|/g;
#  $word=~s/  / /g;
#
#    $word=~s/ \'/\'/g;
#    $word=~s/ \"/\"/g;
#    $word=~s/\' /\'/g;
#    $word=~s/\" /\"/g;
#   
 #    print "$word\n";  
  }
  
  print OUT "$f[0]\t$word\t$f[2]\n";

} # elihw

close(FILE);
close(OUT);

# special chars:


exit();

