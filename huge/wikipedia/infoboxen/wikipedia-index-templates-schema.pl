#!/usr/bin/env perl-588 -w 

use YAML;
local $YAML::UseAliases     = 0;
local $YAML::CompressSeries = 1;
local $YAML::UseHeader      = 0;
use XML::Simple;
use Data::Dumper;
local $Data::Dumper::Pair   = ": "; 
local $Data::Dumper::Indent = 1;
use Text::Balanced	qw{ extract_tagged extract_bracketed };

# http://en.wikipedia.org/wiki/Special:Export

exporturl="http://en.wikipedia.org/w/index.php?title=Special:Export&action=submit&dir=desc&limit=1";
for foo in `head -200 templatefiles-list.txt ` ; do \
   if [[ -f "$foo.xml" ]] ; then \
       echo "got it"; \
   else
       wget "${exporturl}&pages=Template:${foo}"     -O "$foo.xml"; \
       wget "${exporturl}&pages=Template:${foo}/doc" -O "$foo-doc.xml"; \
   fi
done

cat ../templates/enwiki-chunk-*-tree.yaml | perl -ne 'm/^        templ_id: / && print;' | \
    sort | uniq -c | sort -rn | head -200 | \
    cut -c 1-200 | \
    perl -pe 's/^[\d\s]+ templ_id: '\''?(.*?)'\''?$/''$1''/; s/ /_/g;' > ./templatefiles-list.txt
    
# kill off null pages wp sends back
# for foo in *-doc.xml ; do if ( diff -q -- nonesuch "$foo" > /dev/null ) ; then mv "$foo" bad/; fi ; done



sub template_schema( $ ) {
    (my ($page)) = @_;
    my $text = $page->{text};

    
    return $page;
}


#
# There's only a few thousand of these so we can use an actual XML parser. yay!
#

# Pull in XML
my $xmldecl = qq{<?xml version='1.0' encoding="utf-8" standalone='yes'?>}; 
my $xmlw = XML::Simple->new(
    RootName => "wikipedia_template_schema",
    XMLDecl => $xmldecl,
    KeyAttr=>{}, ForceArray=>['page','revision',], NoSort => 1, # NoAttr => 1,
    GroupTags=>{'pages'=>'page', 'template'=>'params' }, 
    ContentKey => 'content',
    );
# print $xmlw->XMLout({'pages' => $wptree});
local $/;
$_ = <>;
my $schematree = $xmlw->XMLin($_); #slurp


my @schema = ();
# print Dumper($schematree);
for my $pagein ($schematree->{page}) {
    $pagein = $pagein->[0];
    
    my $page = {};
    $page->{id}    = $pagein->{id};
    $page->{title} = $pagein->{title};
    $page->{text}  = $pagein->{revision}->[0]->{text}->{content};

    
    $page = &template_schema($page);
    $page->{text}  = 0;
    
    # push @schema, $page;
    # print Dumper($page);
}


# print Dump($schema);


# quiet an annoying warning
sub shutup_warning_monster_shutup_shutup_shutup { printf "%s - %s - %s\n", $YAML::UseAliases, $YAML::CompressSeries, $YAML::UseHeader;}


# <text xml:space="preserve">#REDIRECT [[Template:Africa topic]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:FixBunching]]{{R to other template|FixHTML}}{{Cat also|} {{PAGENAME}}| Formatting templates | MSIE font fix templates | Typing-aid templates}}</text>
# <text xml:space="preserve">#REDIRECT[[Template:Football squad player]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Harvard citation]]</text>
# <text xml:space="preserve">#REDIRECT[[Template:Harvard citation no brackets]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Infobox Settlement/doc]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Infobox Settlement]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Infobox Musical artist/doc]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Infobox Musical artist]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Geolinks-US-cityscale]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:Baseball Year]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:End]]</text>
# <text xml:space="preserve">#REDIRECT [[Template:See also]]</text>
# <text xml:space="preserve">#REDIRECT [[template:s-start]] {{R from other template|s-start}}</text>

# Yaml showing all redirects
# echo "template_redirects:" ; grep  '#REDIRECT' * | perl -ne 'if ((my ($from, $to)) = m/([^\:]*)\.xml:.*#REDIRECT\s*\[\[(.*?)\]\]/s) { $to=~s/Template\://s; $to=~s/\s/_/g; printf " - %-40s %s\n", "$from:", "\"$to\""; } else { print "$_\n"; }'

# # parts of each page 
# my %strings = reverse (
#     'startdoc', 	qr/-- EDIT TEMPLATE DOCUMENTATION BELOW THIS LINE --/,
#     'usage',		qr/==+\s*usage==+/i,
#     'parameters',	qr/==+\s*parameters==+/i,
#     'microformats',	qr/==+\s*microformats==+/i,
#     'example',		qr/==+\s*example==+/i,
#     'cats_and_iw',	qr/ADD .*(CATEGORIES|INTERWIKIS).*/i,
#     );
#
# my %found = ();
# for my $line (split '[\n]', $text) {
# 	for my $re (keys %strings) {
# 	    if ($line =~ $re) {
# 		$found{$strings{$re}}++;
# 	    }
# 	}
# }
# 
# printf "%s\t", (join " ",
# 	map { sprintf "%12s %2s ", ($found{$_} ? ($_,$found{$_}) : ('','')) } (values %strings) );
