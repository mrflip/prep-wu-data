#!/usr/bin/env perl-588 -w -CLADS

use strict;

#
# Record:
#  - each page title,
#  - its offset in the file,
#  - every {{}} template in the joint
#  - Redirects
#
# By bringing the templates in wholesale, you can parse your heart away on the
# several megabyte digest files rather than the ~15 gigabyte (2008) full-text.
#
#
# We're not really /parsing/ the file: we're not parsing the XML, and we're not
# parsing the mediawiki markup.  Not parsing the XML is no problem, as the dumps
# all come in a regular format, amenable to line-level munging.
#
# We don't parse the wikitext because we just want to strip out the semantic
# information as quickly and efficiently as we can.
#
# This means we pitch out things like '[[links]] that span a line' and
# 'templates with unbalanced {{}}' (see below).  In practice that we lose a lot
# of [[Image]] links and not much else of interest.  There are a couple thousand
# unparseable templates out of several million pages; about 1/10,000 templates
# winds up dead.
# 
#
# Assumptions:
#  - the xml part of page structures have the same structure.
#  - html tags within the text are escaped.
#  - <page> tags always have no attributes.
#
# Notes
#
#   - Page elements are in order: you can tell what section each link came
#     under, etc.
#
#   - Quote marks ' are escaped to '' marks.
#
#   - Newlines are replaced with spaces, so you can efficiently use grep in the
#     output yaml.  If this doesn't work for you then change the line in the
#     &escape() subroutine.
#
#   - No other characters are escaped in the YAML output.  In particular, some
#     characters which are illegal in XML 1.0 are left in. (The yaml2xml
#     script strips them out)
#
#   - Links and templates can freely interweave. A link inside a template or
#     a template inside a link will appear in each context.
#
#   - We emit only the outer bracketing {{ }}s: for nested templates, the inner
#     templates appear only in the context of the enclosing.
#
#   - We take only links that fit on one line (well, we only take links that
#     have a matching ]] on the line.)
#
#   - Only [...] content like '[http:// ...no brackets... ]' is taken to be a
#     hyperlink.
#
#   - Since we occasionally do things like ditch an opening {{ or [[ that was
#     found to often cause trouble, we silently permit overruns: for {{foo}}}}
#     we don't worry about the extra }}s.
#
# Improvement:
#
#   - could take pages with troublesome links and parse their content properly
#

# lowercase for comparison
my %tags_ignore = map { $_=>1 } qw{r fullurl lc lcfirst localurl uc ucfirst urlencode yes no defaultsort convert · - };

#
# my %tags_simple = qw{ disambig 1 ipa 1 gfdl 1 small 1 1 2 1 3 1 4 1 5 1 6 1 7 1 8 1 9 };

my $bytes     = 0;
my $megabytes = 0;
use constant MB => (2**20);

sub escape($) {
    (my ($str)) = @_;
    $str =~ s/'/''/gos;
    $str =~ s/[\r\n]+/ /gos;  # NOTE -- replace newline with space
    return $str;
}

sub summarize($) {
    (my ($str)) = @_;
    $str =~ s/'/''/gos;
    $str =~ s/[\r\n]+/ !!NL!! /gos;
    return $str;    
}

sub warn_bad($$$$$) {
    (my ($what, $str, $line, $page, $dump_anyway)) = @_;
    warn (sprintf "Bad %s, abandoning %d chars at %9d on page %-35s %s...",
	$what, (length $str), $line, "$page:", substr(&summarize($str),0,500));
    printf "    - template_bad: [ %d, '%s', '%s' ]\n", $line, &summarize($page), &summarize($str) if $dump_anyway;
}

print "wikipedia_index:\n";
my @links     = ();
my @templates = ();		 
my $squarebracket_depth = 0;	my $link_string         = ""; # links:     one set of nested [[ ]]'s	
my $curlybracket_depth  = 0;	my $template_string     = ""; # templates: one set of nested {{ }}'s	

my $linenum      = 0;
my $pagetitle    = '';
my $pageid       = 0;
my $in_textblock = 0;
my $skipme       = 0;
while (my $line = <>) {
    # record file offset
    $linenum++;
    $bytes += length($line);
    if ($bytes > MB) { $megabytes++; $bytes -= MB; };

    #
    # Page
    #
    if ( (my $page_offset = index($line,'<page>')) != -1) {
	$pagetitle    = '';
	$pageid       = 0;
	$in_textblock = 0;
	$skipme       = 0;
	if ($curlybracket_depth)  { &warn_bad("template", $template_string, $., $pagetitle, 1); $curlybracket_depth  = 0; }
	# recorded bytes offset could be negative, who cares.
	printf " - page: \n    - offsetMiB: %s\n    - offsetB: %s\n",
		$megabytes, ($bytes - length($line) + $page_offset);
	$line = substr($line, $page_offset + length('<page>'));	# GOBBLE
    };

    #
    # Title
    #
    if ( (my $page_offset = index($line,'<title')) != -1) {
	$line =~ m!<title[^>]*>(.*?)</title>(.*)$!io;
	printf "    - title: '%s'\n", &escape($1);
	$pagetitle = $1;
	$line      = $2;  # GOBBLE
	# Don't track templates, links etc except in main, Help:, Category:, and Portal:
	if ($pagetitle =~ m!((?:Media|Special|Talk|User|Wikipedia|Image|MediaWiki|Template|)(?: Talk)?)\:!i) {
	    $skipme = 1;
	}
    };
    
    #
    # ID
    #  - lots of things have id's; we depend on the page id being first.
    #
    if ( ((my $page_offset = index($line,'<id')) != -1) &&
	 ($pageid == 0) ) {
	$line =~ m!<id>(.*?)</id>(.*)$!io;
	$pageid    = $1;
	$line      = $2; # GOBBLE
	printf "    - id: %s\n", $pageid; # OK to not escape: number
	printf "    - titleid: [ %s, '%s' ]\n", $pageid, &escape($pagetitle); # For convenience in line-level grep'ing
    };

    #
    # Redirects
    #
    if ( (my $page_offset = index($line,'#REDIRECT')) != -1) {
	if ($line =~ m!#REDIRECT.*?\[\[(.*?)\]\]!o) {
	    my $redirect = escape($1);
	    printf "    - redirect: {from: '%s', to: '%s'}\n", &escape($pagetitle), &escape($redirect);
	}
    };

    #
    # Text block?
    #
    if (index($line,'<text') != -1) {
	$in_textblock = 1;
    }

    #
    # Skip rest unless in the interesting namespaces and in a <text> block
    #
    if ((!$skipme) && ($in_textblock)) {

	#
	# Strip out Comments, Math and Nowiki
	#
	if ( (my $page_offset = index($line,'&lt;math')) != -1)   { $line =~ s!\&lt\;math.*?/math\&gt\;!  !g; };
	if ( (my $page_offset = index($line,'&lt;nowiki')) != -1) { $line =~ s!\&lt\;nowiki.*?/nowiki\&gt\;!  !g; };
	if ( (my $page_offset = index($line,'&lt;!--')) != -1)    {
	    $line =~ s!\&lt\;\!--(.*?)--\&gt\;?!  !g or $line =~ s!\&lt\;\!--.*?!  !g;	    
	};

	#
	# Sections
	#
	if ( $line =~ m!(==+[^=]+==+)!) {
	    my $section = escape($1);
	    printf "    - section: '%s'\n", &escape($section);
	};

	#
	# Links
	#
	if ( (my $page_offset = index($line,'[')) != -1) {
	    for my $link ($line =~ m{(\[\[.*?\]\])}) {
		printf "    - link: '%s'\n", &escape($link);
	    };
	    for my $hyperlink ($line =~ m{(?<!\[)(\[http://[^]]+\])} ) {
		printf "    - hyperlink: '%s'\n", &escape($hyperlink);
	    };
	}

	#
	# Templates
	#     {{[^A-Za-z#0-9 	\\·&?-]
	#   Skip templates that don't begin with something promising
	my @segments = split /((?:\{\{)|(?:\}\}))/, $line;
	while (@segments) {
	    my $seg = shift @segments;
	    if ($seg eq '{{') {
		# the editnote ones are never closed: wtf?
		if (! ($segments[0] =~ /editnote/) ) {
		    $curlybracket_depth++;
		}
	    }
	    if ($curlybracket_depth > 0) {
		$template_string .= $seg;
	    }
	    if ($seg eq '}}') { $curlybracket_depth-- if ($curlybracket_depth > 0); }
	    if (($seg eq '}}') && ($curlybracket_depth == 0)) {
		$template_string =~ s!\A{{\s*(?:Template:)?!{{!;   # kill inital whitespace
		$template_string =~ m!\A{{(\W+\w+?)\s!;            # identify first wordpart
		my $template_tag = lc ($1 || '');
		my $skip = ($tags_ignore{$template_tag} || ($template_string =~ m/\A{{#/) );
		
		printf "    - template: '%s'\n", &escape($template_string) unless $skip;
		$template_string = '';
	    }
	}
    }
    if (index($line,'</text>') != -1) {
	$in_textblock = 0;
	if ($curlybracket_depth)  { &warn_bad("template", $template_string, $., $pagetitle, 1); $curlybracket_depth  = 0; }
    }
    
}
