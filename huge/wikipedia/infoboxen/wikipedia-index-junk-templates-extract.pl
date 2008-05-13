#!/usr/bin/env perl -w -CLADS
use strict;

# http://en.wikipedia.org/wiki/Special:Export


#
# Simple stupid parser
#  - We first build a tree of {{}} structures,
#  - Then we bust each up into arrays along |'s
#

# sub curly_tree( $\@ ) {
#     (my ($text)) = @_;
# 
#     my @segments = split /((?:\{\{)|(?:\}\}))/, $line;
#     while (@segments) {
# 	my $seg = shift @segments;
# 	if ($seg eq '{{') {
# 	    # the editnote ones are never closed: wtf?
# 	    if (! ($segments[0] =~ /editnote/) ) {
# 		$curlybracket_depth++;
# 	    }
# 	}
# 	if ($curlybracket_depth > 0) {
# 	    $template_string .= $seg;
# 	}
# 	if ($seg eq '}}') { $curlybracket_depth-- if ($curlybracket_depth > 0); }
# 	if (($seg eq '}}') && ($curlybracket_depth == 0)) {
# 	    $template_string =~ m!^{{(\w+)\W!;
# 	    my $template_tag = $1 || '';
# 	    # push @templates, $template_string if (!$tags_ignore{lc $template_tag});
# 	    printf "    - template: '%s'\n", &escape($template_string) if (!$tags_ignore{lc $template_tag});
# 	    $template_string = '';
# 	}
#     }
#     
# }

sub curly_tree( \@ ) {
    (my ($segs)) = @_;
    while (@segs) {
	
    }
}

sub simple_parse_template( $ ) {
    (my ($text)) = @_;
    my @segments = split /((?:\{\{)|(?:\}\}))/, $line;

	
}
    

    


my %tags = ();
my $total_tags = 0;
my $title = '';
my $id    = 0;
while (my $line = <>) {
    # title, id
    if ($line =~ m/^\s+- titleid: \[ (\d+), '.*' \]/o) {
	$id    = $1;
	$title = $2;
    }

    # could do section, etc if we wanted.
    
    # Template
    if ($line =~ m/^\s+- template: '\{\{\s*(.+)\}\}/so) {
	
	# Bust apart at | pipes 
	my @parts = split '\s*|\s*', $1;
	# Canonicalize name
	$parts[0] =~ s/ /_/; 
	# Record name, count, etc.
	my $tagname = $parts[0]; 
	my $tag = $tags{lc $tagname};
	$tag->{name} = $tagname;
	$tag->{total}++;  $total_tags++;
	
	# Record contents
	push @{$tag->{instances}}, \
	{ 'title'   => $title,
	  'id'      => $id,
	  'n_args'  => (scalar @parts),
	  'conts'   => \@parts,
	}

	# classify
	my @opens = ($line =~ m/(\{\{)/g); my @closes = ($line =~ m/(\}\})/g);
	#if ($line =~ m/cquote/) { printf STDERR "%d %d %s", $opens, $closes, $line; }
	if    ( ($#opens == 0) && ($#closes == 0) ) { $tag->{simple}++;     }
	elsif ( ($#opens == $#closes) )             { $tag->{balanced}++;   }
	else                                        { $tag->{unbalanced}++; }
	$tags{lc $tagname} = $tag;
    } 
}

my $min_count = 10;
printf "## Analyzed %s tags with %s occurrences\n", (scalar keys %tags), $total_tags;
print "## Skipping unbroken simple tags with fewer than $min_count occurrences\n";
for my $tag (sort { $a->{total} <=> $b->{total} } values %tags) {
    # count non-simple
    my $non_simple = ( ($tag->{total}||0) - ($tag->{simple}||0) );
    # skip boring 
    next unless ( ($tag->{total} >= $min_count) );

    # percent of all tags
    my $pct = 100*($tag->{total} / ($total_tags));
    my $pct_s = ($pct < 0.1) ? '' : (sprintf "(%5.1f%%)", $pct);

    # percentages of this tag
    my $tag_type = '-';
    for my $type (qw{simple balanced unbalanced broken}) {
	# coerce to defined
	$tag->{$type} ||= 0;
	# percentage
	$tag->{"pct_${type}"}   = 100*($tag->{$type} / $tag->{total});
	$tag->{"pct_s_${type}"} = ($tag->{"pct_${type}"} < 0.1) ? '-' : (sprintf "(%5.1f%%)", $tag->{"pct_${type}"});
	# classify
	$tag_type = $type if (($tag->{"pct_${type}"} > 99.5) && ($tag->{total} > 10));
    }
  
    # dump
    printf("%-10s All:%7s %8s s:%7s %8s v %6s b:%7s %8s u:%7s %8s br:%7s %8s || %s\n",
	$tag_type,
	$tag->{total}      ||'-', $pct_s,
	$tag->{simple}     ||'-', $tag->{"pct_s_simple"},
	($non_simple ? (sprintf "%6d",$non_simple) : '-'),
	$tag->{balanced}   ||'-', $tag->{"pct_s_balanced"}, 
	$tag->{unbalanced} ||'-', $tag->{"pct_s_unbalanced"}, 
	$tag->{broken}     ||'-', $tag->{"pct_s_broken"}, 
	$tag->{name},
	);
}
