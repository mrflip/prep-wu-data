#!/usr/bin/perl 

use Data::Dumper;
use strict;

local $/ = undef;
$_ = <>;

#   s!\s*<div class="team">\s*<a href="([^"]*)" class="fn org url">([^>]*)</a><br/>\s*<a href="([^"]*)" class="logo"><img class="logo" src="http://mlb.com/mlb/images/team_logos/([^"]*)" width="79" height="76" alt="[^"]*" /></a>\s*<div class="adr">\s*<span class="extended-address">([^>]*)\s*(?:<br/>)?\s*([^>]*)</span><br/>\s*<span class="street-address"\s*>([^>]*)</span><br/>\s*<span class="locality"\s*>([^>]*)</span>, <span class="region">([^>]*)</span> <span class="country-name">([^>]*)</span> <span class="postal-code">([^>]*)</span>\s*</div>\s*<span class="tel"\s*>([^>]*)</span><br/>\s*<a class="([^"]*)" href="([^"]*)">([^>]*)</a><br/>\s*<br/>\s*</div>!!sog &&
    s{\s*<div class="team">\s*<a href="[^"]*" class="fn org url">([^>]*)</a><br/>\s*<a href="([^"]*)" class="logo"><img class="logo" src="http://mlb.com/mlb/images/team_logos/([^"]*)" width="79" height="76" alt="[^"]*" /></a>\s*<div class="adr">\s*<span class="extended-address">([^>]*?)[ \t]*(?:<br/>)?\n[ \t]*([^>]*)</span><br/>\s*<span class="street-address"\s*>([^>]*)</span><br/>\s*<span class="locality"\s*>([^>]*)</span>, <span class="region">([^>]*)</span> <span class="country-name">([^>]*)</span> <span class="postal-code">([^>]*)</span>\s*</div>\s*<span class="tel"\s*>([^>]*)</span><br/>\s*<a class="[^"]*" href="[^"]*">[^>]*</a><br/>\s*(?:<a class="[^"]*" href="([^"]*)">[^>]*</a><br/>\s*)?\s*(?:<br/>)?\s*</div>}
     {<team name="$1" logofile="$3" extaddr1="$4" extaddr2="$5" streetaddr="$6" locality="$7" region="$8" country="$9" zip="$10" tel="$11" url="$2" spanishurl="$12" />\n}sog ;

for my $line (split "\n", $_) {
    $line =~ m{<team name="([^"]*)" logofile="([^"]*)" extaddr1="([^"]*)" extaddr2="([^"]*)" streetaddr="([^"]*)" locality="([^"]*)" region="([^"]*)" country="([^"]*)" zip="([^"]*)" tel="([^"]*)" url="http://([^"]*)" spanishurl="(?:http://)?([^"]*)" />} &&
    printf "<team name=%-31s logofile=%-20s extaddr1=%-32s extaddr2=%-15s streetaddr=%-31s locality=%-16s region=%-4s country=%-4s zip=%-12s tel=%-16s url=%-25s spanishurl=%-25s />\n",
        "\"$1\"", "\"$2\"", "\"$3\"", "\"$4\"", "\"$5\"", "\"$6\"", "\"$7\"", "\"$8\"", "\"$9\"", "\"$10\"", "\"$11\"", "\"$12\"";
}


#    s{\s*<div class="team">\s*<a href="([^"]*)" class="fn org url">([^>]*)</a><br/>\s*<a href="([^"]*)" class="logo"><img class="logo" src="http://mlb.com/mlb/images/team_logos/([^"]*)" width="79" height="76" alt="([^"]*)" /></a>\s*<div class="adr">\s*<span class="extended-address">([^>]*)\s*(?:<br/>)?\s*([^>]*)</span><br/>\s*<span class="street-address"\s*>([^>]*)</span><br/>\s*<span class="locality"\s*>([^>]*)</span>, <span class="region">([^>]*)</span> <span class="country-name">([^>]*)</span> <span class="postal-code">([^>]*)</span>\s*</div>\s*<span class="tel"\s*>([^>]*)</span><br/>\s*<a class="([^"]*)" href="([^"]*)">([^>]*)</a><br/>\s*(?:<a class="([^"]*)" href="([^"]*)">([^>]*)</a><br/>\s*)?\s*(?:<br/>)?\s*</div>}

#    s{\s*
#    <div class="team">\s*
#      <a href="[^"]*" class="fn org url">([^>]*)</a><br/>\s*
#	<a href="([^"]*)" class="logo"><img class="logo" src="http://mlb.com/mlb/images/team_logos/([^"]*)" width="79" height="76" alt="[^"]*" /></a>\s*
#       <div class="adr">\s*
#	  <span class="extended-address">([^>]*)\s*(?:<br/>)?\s*([^>]*)
#         </span><br/>\s*
#	  <span class="street-address"\s*>([^>]*)</span><br/>\s*
#	  <span class="locality"\s*>([^>]*)</span>, 
#	  <span class="region">([^>]*)</span> 
#	  <span class="country-name">([^>]*)</span> 
#	  <span class="postal-code">([^>]*)</span>\s*
#	</div>\s*
#	<span class="tel"\s*>([^>]*)</span><br/>\s*
#	<a class="url english" href="[^"]*">[^>]*</a><br/>\s*
#    (?:<a class="url spanish" href="([^"]*)">[^>]*</a><br/>\s*)?\s*(?:<br/>)?\s*
#    </div>}

#    <div class="team">
#      <a href="orioles.com" class="fn org url">Baltimore Orioles</a><br/>
#      <a href="http://orioles.com" class="logo"><img class="logo" src="http://mlb.com/mlb/images/team_logos/logo_bal_79x76.jpg" width="79" height="76" alt="Baltimore Orioles Logo" /></a>
#      <div class="adr">
#        <span class="extended-address">Oriole Park at Camden Yards
#        </span><br/>
#        <span class="street-address"  >333 West Camden Street</span><br/>
#        <span class="locality"        >Baltimore</span>, <span class="region">MD</span> <span class="country-name">US</span> <span class="postal-code">21201</span>
#      </div>
#      <span class="tel"             >(410) 685-9800</span><br/>
#      <a class="url english" href="http://orioles.com">orioles.com</a><br/>
#      <br/>
#    </div>

# <team name="$1" logofile="$3" extaddr="$4" streetaddr="$5" locality="$6" region="$7" country="$8" zip="$9" tel="$10" url="$2" spanishurl="$11" />











#     <div class="team">
#       <a href="orioles.com" class="fn org url">Baltimore Orioles</a><br/>
#       <a href="http://orioles.com" class="logo"><img class="logo" src="http://mlb.com/mlb/images/team_logos/logo_bal_79x76.jpg" width="79" height="76" alt="Baltimore Orioles Logo" /></a>
#       <div class="adr">
#         <span class="extended-address">Oriole Park at Camden Yards
#         </span><br/>
#         <span class="street-address"  >333 West Camden Street</span><br/>
#         <span class="locality"        >Baltimore</span>, <span class="region">MD</span> <span class="country-name">US</span> <span class="postal-code">21201</span>
#       </div>
#       <span class="tel"             >(410) 685-9800</span><br/>
#       <a class="url english" href="http://orioles.com">orioles.com</a><br/>
#       <br/>
#     </div>






















# <!-- 
# <![CDATA[for url in `grep 'logos' ../parkinfo-mlb.xml | \
#     perl -ne 's!.*src="([^"]*)".*!http://mlb.mlb.com/$1!; print'` ; do wget $url -nc -nv -nH --cut-dirs=3 "$url" ; done
#
# [ 	]+<a href="\([^"]+\)" class="hlXs">\(.*\)</a><br/>
# [ 	]+<a href="[^"]*">\(<img src=".*logo_.*.jpg".*/>\)</a>
# [ 	]+\(.*<br/>
# [ 	]*.*\)
# [ 	]+\(.*\)<br/>
# [ 	]+\(.*, .*\(, .*\)? .*\)<br/>
# [ 	]+Phone: \(([0-9]+) [0-9\-]+\)<br/>
# [ 	]*<a class=".*
# [ 	]*\(<a .*href="[^"]*".*</a>\)?
# [ 	]+<p />
#
# <div class="team" name="\1">
# 	<a href="\1" class="fn org url">\2</a><br/>
# 	<span class="url spanish">\9</span><br/>
# 	<a href="\1" class="logo">\3</a><br/>
#   <div class="adr">
# 		<span class="extended-address">\4</span>
# 		<span class="street-address"  >\5</span>
# 		<span class="cscz">\6</span>
#     <span class="tel"             >\8</span>
#   </div>
# </div>
#
#
# <span class="cscz">\(.*\), \(.*\)\(, .*\)? \(.*\)</span>
# <span class="locality"        >\1</span>, <span class="region">\2</span> <span class="country-name">\3</span> <span class="postal-code">\4</span>
#
# \(<div class="team" name=".*">\)
# 	<a href="http://\(www\.\)?\([^"]*\)" class="fn org url">\(.*\)</a><br/>
# 	<span class="url spanish">\(<a class="hlXs" href="http://\(www\.\)?\([^"]*\)">[^<]*</a>\)?</span><br/>
# \(.*
# .*
# .*
# .*
# .*
# .*
# .*
#   </div>\)
# </div>
#
# \1
# 	<a href="\3" class="fn org url">\4</a><br/>
#   \8
# 	<a class="url english" href="http://\3">\3</a></span><br/>
# 	<a class="url spanish" href="http://\7">\7</a></span><br/>
# </div>
#
# ]]>-->


