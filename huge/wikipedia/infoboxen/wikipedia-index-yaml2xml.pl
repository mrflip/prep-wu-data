#!/usr/bin/env perl-588 -w -CLADS

use YAML::Syck;
use XML::Simple;
use Data::Dumper;

#
# Convert the YAML output by the indexer into XML
#
# The XML structure is kept regular and simple, simple enough for perl's
# XML::Simple to handle or even for line-level grep'ing.
#

local $/;
$_=<>;
(my $wptree) = Load($_);
$wptree = $wptree->{wikipedia_index};
# print Dumper($wptree);

# pivot data structure into colloquial XML
for (my $i=0; $i <= $#{$wptree}; $i++) {
    my $page = $wptree->[$i];

    my $newpage = {  };
    my @elts = ();
    for $elt (@{$page->{page}}) {
	my $eltkey = (keys %{$elt})[0];
	my $eltval = $elt->{$eltkey};

	# Strip out characters illegal in XML 1.0
	# -- see http://fatphil.org/perl/demoroniser.pl
	#
	# If you want, change the XMLDecl below to 1.1 and do a s/\xXX/ENTITY/;
	# on the element's value. XML::Simple may complain but I think the
	# output will still be valid XML 1.1.  If you do this please send back
	# the mod.
	#
	# HACK HACK HACK
	$eltval =~ tr/\x00-\x08\x10-\x1F//d;  # also: \x80-\x9F? 

	#
	# make all the page elements (section, link, hyperlink, template, etc)
	# into an attribute'd <elt type="">...</elt> tag: this makes it easy to
	# dump them out preserving order, and makes XML::Simple do the right
	# thing.
	#
	# we kill off the titleid tag because it's redundant in the XML
	# (it's only emitted to let you grep for (id, title) pairs)
	#
      SWITCH: for ($eltkey) {
	  m/id/        && do { $newpage->{$eltkey} = $eltval; last; };
	  m/title/     && do { $newpage->{$eltkey} = $eltval; last; };
	  m/titleid/   && do { last; }; # delete -- don't need.
	  m/offset/    && do { $newpage->{$eltkey} = $eltval; last; }; # either one
	  m/redirect/  && do { $newpage->{redirect} = $eltval; last; };
	  # else 
	  push @elts, { 'type'=>$eltkey, 'content'=>$eltval }; last;
      }
    }
    $newpage->{elt} = \@elts;
    $wptree->[$i] = $newpage;
}

# dump data structure
# print Dumper($wptree);

# Dump to XML
my $xmldecl = qq{<?xml version='1.0' encoding="utf-8" standalone='yes'?>}; 
my $xmlw = XML::Simple->new(
    RootName => "wikipedia_index",
    XMLDecl => $xmldecl,
    KeyAttr=>['type'], ForceArray=>[], NoSort => 1, # NoAttr => 1,
    GroupTags=>{'pages'=>'page'}, 
    ContentKey => 'content',
    );
print $xmlw->XMLout({'pages' => $wptree});
