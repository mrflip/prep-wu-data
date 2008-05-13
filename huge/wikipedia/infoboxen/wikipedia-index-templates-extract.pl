#!/usr/bin/env perl-588 -w -CLADS

use YAML::Syck;
# local $YAML::UseFold        = 1;
# local $YAML::UseAliases     = 0;
# local $YAML::CompressSeries = 1;
# local $YAML::UseHeader = 0; # else Dump will put each page as its own document
local $YAML::Syck::Headless = 1;
local $YAML::Syck::SortKeys = 1;
local $YAML::Syck::SingleQuote = 1;
local $YAML::Syck::ImplicitUnicode = 1;
    
use XML::Simple;
use Data::Dumper;
local $Data::Dumper::Pair   = ": "; 
local $Data::Dumper::Indent = 1;
use Text::Balanced	qw{ extract_tagged extract_bracketed };

# http://en.wikipedia.org/wiki/Special:Export

# usage:
#
# time ( cat templates/enwiki-chunk-120-template.yaml | \
#            ./wikipedia-index-templates-extract.pl  > \
#            templates/enwiki-chunk-120-tree.yaml ) 2>&1 | cut -c 1-200
#
# for stats:
#    cat templates/enwiki-chunk-120-tree.yaml | perl -ne 'm/^      - id: /&&print;' | sort | uniq -c | sort -n
#
#

sub template_tree( $ ) {
    (my ($text)) = @_;
    # break at open/close   {{      }}        [[      ]]    or    | pipes
    my @segs = split /((?:\{\{)|(?:\}\})|(?:\[\[)|(?:\]\])|(?:\s*\|\s*))/, $text;
    shift @segs; # kill empty '' string at start
    # @segs = @segs[2..($#segs-1)];
    
    (my ($tree, $newsegs)) =  &expand_tree(\@segs, 0);
    if (@$newsegs) { warn 'Extra cruft: '.(Dumper($newsegs)) };
    return $tree->[0];
}

#
# pull off named params, setting them in order (so the last specified wins) and
# separately keep positional ones, in the order that remains when the named args
# have been pulled out.  See
#   http://meta.wikimedia.org/wiki/Help:Template#Template_tag_lay-out
#
#   Mix of named and unnamed parameters
# 
#   In the case of a mix of named and unnamed parameters in a template tag,
#   the unnamed parameters are numbered 1,2,3,.., so they are not numbered
#   according to the position in the mixed list as a whole.
# 
#   For example, {{t sup|3=1|2|1=3|4|5|6|7}} using Template:t sup containing
#   "{{{1}}}-{{{2}}}-{{{3}}}<noinclude> [[Category:templates]]</noinclude>"
#   gives 3-4-5.
#
#
sub template_from_params( \@$$ ) {
    (my ($params, $pageid, $pagetitle)) = @_;    
    my %template = ();

    # first part is the template ID
    $template{templ_id}  = (shift @$params)||'';
    $template{templ_id}  =~ s/COMMENT//g;            # FIXME - left in from an old version.
    $template{templ_id}  =~ s/ /_/g;		     # spaces to underbars.	
    $template{templ_id}  =~ s/\A_*(.*?)_*\Z/$1/;     # Kill whitey. space at end of line.
    $template{pageid}    = $pageid;
    $template{pagetitle} = $pagetitle;

    # named params become { key : val }
    # others go in as order of unnamed'ness
    my %new_params = ();
    my $index = 1;
    for my $param (@$params) {
	# Param with '=' before its first bracket is named
	if ( (my ($key, $val)) = ($param =~ m/^([^\=]*?)\s*\=\s*(.*?)$/) ) {
	    $new_params{$key} = $val;
	}
	else {	# else positional
	    $new_params{$index} = $param ;
	    $index++;
	}
    }
    $template{params} = \%new_params;
    return \%template;
}

#
# Just get the list of params, leaving any nested templates or links alone.
#
# FIXME -- should 

sub template_flat( $$$ ) {
    (my ($text, $pageid, $pagetitle)) = @_;
    $text =~ s/^{{\s*(.*?)\s*\}\}$/$1/ or warn "cruft in '$text': want text to start and end like {{ }}";

    my @params = ('');
    my ($bracketed, $head);
    my $trips = 0;
    while ($text) {
	# get the chunk up to any [[ or {{ and split it for params
	if   ($text !~ m/\{\{|\[\[/) { $head = $text; $text = '' }
	else { ($head, $text) = ($text =~ /\A(.*?)((?:\{\{|\[\[).*)\Z/); }
	
	# yuck. OK, the leading part gets tacked on the last bit (it was bracketed)
	(my ($f, @r)) = split '\s*\|\s*', $head; $f = '' unless defined $f;
	$params[$#params] .= $f;
	# and the rest are params of their own.
	push @params, @r;
	last unless $text;

	# Hm. A bracketed part... strip it off (including of course all embedded {}[]'s) 
	($bracketed, $text) = &extract_tagged($text, qr/\{\{|\[\[/, qr/\}\}|\]\]/, undef, { fail=>'MAX' });
	if (! defined $bracketed) { warn "Ill-formed '$text'"; }
	# $text =~ s/^(\{|\[[^\{\}\[\]]*)([\{\}\[\]])/$1
	
	# and tack it on to the the end of the last bit of text we saw.
	$params[$#params] .= $bracketed;
	# HACK HACK HACK bail on unparseable
	$trips++; if ($trips > 999) { warn "WTF $trips trips parsing $text"; last; }
    }
    return &template_from_params(\@params, $pageid, $pagetitle);
}

#
# Better: Do line-level parsing.
#
sub digest_tree_hacky( ) {
    # emit first line as header
    my $line = <>;  
    print $line;
    my $linenum = 1;

    # my $page = {};
    my @templates = ();
    while ($line = <>) {
	$line =~ s/''/'/g;
	$linenum++; print STDERR ($linenum/10000)."*10k\t" if ($linenum % 10000 == 0);
      SWITCH: for ($line) {
	  # m/^ - page:/ && do {
	  #     $page->{templates} = \@templates;
	  #     print Dump([ { 'page' => $page } ]) if @templates;
	  #     @templates = ();
	  #     $page = {};
	  #     last SWITCH;
	  # };
	  m/^\s+- titleid: \[ (\d+), '(.*)' \]$/ && do {
	      ($page->{id}, $page->{title}) = ($1, $2);
	      last SWITCH;
	  };
	  m/^\s+- template: '(.*)'$/  && do {
	      my $template_text = $1;
	      if ( (! $template_text) ||
		   ($template_text =~ m/\A{{\s*(?:[\w\-]+-stub|yes|no|DEFAULTSORT|(?:[·-]\W*\})|convert)/i)
		  ) { last SWITCH; }
	      $template_text =~ s/\A\{\{lang-(\w\w)\|/{{lang|$1|/;
	      
	      # push @templates, $template;
	      my $template = &template_flat($template_text, $page->{id}, $page->{title});
	      print Dump([ $template ]);
	      last SWITCH;
	  };
	  m/^ - page:/ && do { last SWITCH; };
	  # else 
	  warn("WTF: $line");
      }
    }
    #$page->{templates} = \@templates;
    #print Dump($page);
}

&digest_tree_hacky();
# print Dumper($wptree);



# # Dump to XML
# my $xmldecl = qq{<?xml version='1.0' encoding="utf-8" standalone='yes'?>}; 
# my $xmlw = XML::Simple->new(
#     RootName => "wikipedia_index",
#     XMLDecl => $xmldecl,
#     KeyAttr=>['type'], ForceArray=>[], NoSort => 1, # NoAttr => 1,
#     GroupTags=>{'pages'=>'page', 'template'=>'params' }, 
#     ContentKey => 'content',
#     );
# print $xmlw->XMLout({'pages' => $wptree});

# quiet an annoying warning
# sub shutup_warning_monster_shutup_shutup_shutup { printf "%s - %s - %s\n", $YAML::UseFold, $YAML::UseAliases, $YAML::CompressSeries, $YAML::UseHeader;}



# #
# # Simple stupid parser
# #  - We first build a tree of {{}} structures,
# #  - Then we bust each up into arrays along |'s
# #
# #  - right now [http:// name] single bracket links are ignored: they don't have
# #    interior |'s
# #
# sub expand_tree( \@$$ ) {
#     my $segs  = shift;		# tokens
#     my $depth = shift;		# tree depth
#     
#     my $tree  = [];
#     my $param = [];
#     my $subtree;
#   BRACKET: while (defined (my $seg = shift @$segs)) {
# 	# printf "%stree <'%s'> looking at '%s', with <'%s'> remaining\n",
# 	# 	'--'x$depth,
# 	# 	(join "','",@$tree), $seg, (join "','",@$segs);
#       SEGSW: for ($seg) {
# 	  # Open Brackets
# 	  m/\{\{/ && do { # print "down..\n";
# 	      ($subtree, $segs) = &expand_tree($segs, $depth+1);
# 	      push @$param, {'template' => $subtree};
# 	      last SEGSW;
# 	  };
# 	  m/\[\[/ && do { # print "down..\n";
# 	      ($subtree, $segs) = &expand_tree($segs, $depth+1);
# 	      push @$param, {'link'     => $subtree};
# 	      last SEGSW;
# 	  };
# 	  # Param Delimiter
# 	  m/\|/   && do { push @$tree, (@$param==1 ? $param->[0] : $param); $param = []; last SEGSW; };
# 	  # Close Brackets
# 	  m/\}\}/ && do { last BRACKET; };
# 	  m/\]\]/ && do { last BRACKET; };
# 	  #else
# 	  push @$param, $seg if ($seg ne '');
#       }
#     }
#     if (@$param) { push @$tree, (@$param==1 ? $param->[0] : $param) };
#     return ($tree,$segs);
# }



# #
# # Turn a list of p=val|q=val2 named parameters into a hash
# # 
# sub template_params_named( \@ ) {
#     (my ($params)) = @_;
#     my %p_hash = ();
#     for my $param (@$params) {
# 	if ( (my ($key, $val)) = ($param =~ m/^([^\=]*?)\s*\=\s*(.*?)$/) ) {
# 	    $p_hash{$key} = $val;
# 	} else {
# 	    warn "Unnamed Parameter in '$param'" if $param; # let null params go by
# 	    $p_hash{$param} = '';
# 	}
#     }
#     return \%p_hash;
# }

    
# #
# # Digest YAML tree
# #
# sub digest_tree_yaml( ) {
#     local $/;
#     (my $wptree) = Load(<>);
#     $wptree = $wptree->{wikipedia_index};
#     my $newtree = [];
#     for $oldpage (@$wptree) {
# 	my $page = {  };
# 	my @templates = ();
# 	for $elt (@{$oldpage->{page}}) {
# 	    my $eltkey = (keys %{$elt})[0];
# 	    my $eltval = $elt->{$eltkey};
# 	  SWITCH: for ($eltkey) {
# 	      m/titleid/   && do { ($page->{id}, $page->{title}) = @$eltval; last; };
# 	      m/template/  && do {
# 		  # push @templates, &template_tree($eltval);
# 		  push @templates, &template_flat($eltval, $page->{id}, $page->{title});
# 		  last;
# 	      };
# 	      warn("WTF: $eltkey");
# 	  }
# 	}
# 	$page->{templates} = \@templates;
# 	push @$newtree, $page;
#     }
#     print Dump($wptree);
#     return $newtree;
# }
