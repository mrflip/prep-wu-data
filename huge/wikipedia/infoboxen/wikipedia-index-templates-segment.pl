#!/usr/bin/env perl-588 -w -CLADS

use YAML::Syck;
# local $YAML::UseFold        = 1;
# local $YAML::UseAliases     = 0;
# local $YAML::CompressSeries = 1;
$YAML::Syck::Headless = 1;
$YAML::Syck::SortKeys = 1;
$YAML::Syck::SingleQuote = 1;
$YAML::Syck::ImplicitUnicode = 1;
    
use XML::Simple;
use Data::Dumper;
local $Data::Dumper::Pair   = ": "; 
local $Data::Dumper::Indent = 1;
use Text::Balanced	qw{ extract_tagged extract_bracketed };


my %same_templ = reverse (
    'Olympics',     	qr/\AOlympics_(.*)\Z/i,
    'lang',         	qr/\Alang[\-_ ]([a-z][a-z])\Z/i,
    '!!Settlement',   	qr/\A((?:Municipalities|(?:Cities_(?:in|and_towns))|City_of|Province_of)_.*)\Z/i,
    'Politics',   	qr/\APolitics_((?:of|in).*)\Z/i,
    'icon',		qr/\a([a-z]{2}_icon)\Z/i,
    );

sub merge_same_template ( $ ) {
    (my ($full,)) = @_;
    my ($prefix, $name, $flavor) = ('','','');

    if ($full =~ m/\A(Infobox|Elementbox|Taxobox|Campaignbox)_/i) { $prefix = $1; };
    $name = $full;
    # match some functionally similar templates
    for $re (keys %same_templ) {
	if ($full =~ $re) {
	    $name = $same_templ{$re};
	    $flavor = $1 || '';
	    last;
	}
    }
    return ( $full, $prefix, $name, $flavor );
}


sub template_structure_census( \@\% ) {
    (my ($templates, $census)) = @_;

    for my $templ (@$templates) {
	my ( $full, $prefix, $name, $flavor ) = &merge_same_template($templ->{templ_id} || '');
	my $tag = lc $name;
	$census->{totals}++;
	$census->{t}->{$tag}->{tag} = $tag;        	 # case- and flavor-stripped name
	$census->{t}->{$tag}->{names}->{$full}++;      	 # name and count of this template
	$census->{t}->{$tag}->{count}++;
	$census->{t}->{$tag}->{par_count} ||= 0; 	 # ensure existence
	for my $param (keys %{$templ->{params}}) {
	    next if (length $param > 60);  		 # KLUDGE roll past parse errors
	    $census->{t}->{$tag}->{params}->{$param}++;  # name and count for this param
	    $census->{t}->{$tag}->{par_count}++;         # count for all params in this template
	}
    }
    return $census;
}

my $census = {};
for my $filename (@ARGV) {
    my $tree     = LoadFile($filename);
    $tree        = $tree->{wikipedia_index};
    # printf "Loaded %8d templates from %s\n", (scalar @$tree), $filename; 

    $census = &template_structure_census($tree, $census);
    # print Dumper($census);
}

# Kill unpopular templates
my $t = $census->{t};
use constant KILL_FEWER_THAN_OCC => 20;
for my $tag (keys %$t) {
    if ( ($t->{$tag}->{count}     < KILL_FEWER_THAN_OCC)   ||
	 ($t->{$tag}->{par_count} < KILL_FEWER_THAN_OCC*4) ) {
	delete $t->{$tag}; next;
    }
}

# Dump census results
for my $tag (sort { -($t->{$a}->{par_count} <=> $t->{$b}->{par_count}) } keys %$t ) {
    printf("%8s| %8s| %4s| %-40s| ", $t->{$tag}->{par_count}, $t->{$tag}->{count},
	(scalar keys %{$t->{$tag}->{params}}), $t->{$tag}->{tag},);
    my %p = %{$t->{$tag}->{params}};
    my @p = sort { -($p{$a} <=> $p{$b}) } keys %p;
    # @p = @p[0..9] if @p > 9;
    printf "%s\n", join '', (map { ($p{$_}>5) ? (sprintf "%4d:%-12s| ",$p{$_},$_):'' } @p);
}

printf "\n\n%s\n%s\n%s\n", '# '.('='x75), '# Template Page Titles', '# '.('='x75);
# Dump yclept
for my $tag (sort { -($t->{$a}->{par_count} <=> $t->{$b}->{par_count}) } keys %$t ) {
    printf("%8s| %8s| %-40s| ", $t->{$tag}->{par_count}, $t->{$tag}->{count}, $t->{$tag}->{tag},);
    my %p = %{$t->{$tag}->{names}};
    my @p = sort { -($p{$a} <=> $p{$b}) } keys %p;
    @p = @p[0..4] if @p > 5;
    printf "%s\n", join '', (map { ($p{$_}>5) ? (sprintf "%4d:%-20s| ",$p{$_},$_):'' } @p);
}

# print Dumper($wptree);
