#!/sw/bin/perl-588 -w -C0

use strict;
use IO::File;
use File::Basename qw{fileparse};
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use XML::Writer;
use Text::CSV_XS;
use Text::CSV_PP;
use Text::CSV::Unicode;
use YAML;
use Encode qw(encode decode);

sub dump_XML($) {
    (my ($dataset)) = @_;
    
    my $xmldecl = qq{<?xml version='1.0' standalone='yes'?>}; # \n<?xml-stylesheet href="math-constant.xsl" type="text/xsl"?>
    my $xmlw = XML::Simple->new(
	RootName => "infochimp",
	KeyAttr=>{}, ForceArray=>[], NoAttr => 1,
	GroupTags=>{'tags'=>'tag', 'contributors'=>'contributor', 'fields'=>'field'},
	XMLDecl=>$xmldecl,
	);
    my $outfilename = "xml/$dataset->{infochimp_head}->{name}.xml";
    open my $fh, ">:encoding(utf-8)", $outfilename or die "Can't open '$outfilename': $!";
    $xmlw->XMLout( $dataset,      OutputFile => $fh );
}

sub dump_YAML($) {
    (my ($dataset)) = @_;
    my $outfilename = "$dataset->{infochimp_head}->{name}.yml";
    open my $fh, ">:encoding(utf-8)", $outfilename or die "Can't open '$outfilename': $!";
    print $fh Dump($dataset);
    
}

sub dump_Dumper($) {
    print Dumper($_[0]);
}

sub mapzip($$) {
    (my ($vals_as_a, $keynames)) = @_;
    return [ map { my %h; @h{@$keynames} = @$_; \%h } @$vals_as_a ];
}

sub splittags($) {
    (my ($tags)) = @_;
    $tags =~ s/[^\s\w]//g;
    return [ (split '\s+', $tags) ]; # map { {'tag'=>$_} } 
}


sub grokfile_csv($$$$) {
    (my ($schema, $sourceinfo, $filename, $keynames)) = @_;
    
    my $csv = Text::CSV_PP->new({ binary => 1, eol => "\n" });
    my $csvout = Text::CSV_PP->new({ binary => 1, eol => "\n" });
    open my $fh, "<:encoding(utf-8)", $filename or die "Can't open '$filename': $!";
    open my $fhfoo, ">:encoding(utf-8)", "foo.csv" or die "Can't open '$filename': $!";
    my @vals;
    # this will break on embedded newlines.  See http://search.cpan.org/~hmbrand/Text-CSV_XS-0.32/CSV_XS.pm
    while (my $row = $csv->getline($fh)) {
	# my @row = split ',', $line;
	my %val; @val{@$keynames} = @$row;
	push @vals, \%val;
	$csvout->print ($fhfoo, $row);
    }
    return {$schema->{name} => \@vals };
}

sub grokfile($$) {
    (my ($schema, $sourceinfo)) = @_;

    my $payload;
    
    my @fields = map { $_->{name} } @{$schema->{fields}};
  SWITCH: for ($sourceinfo->{format}) {
      /^csv$/  	&& do { $payload = grokfile_csv($schema, $sourceinfo, $sourceinfo->{infile}, \@fields); last; };
      die "Unexpected format '$_'!";
    }

    return $payload;
}

# pull in initial schema
my $cfgfile = $0;
$cfgfile =~ s/parse\.pl/schema-in.yml/;
print "Reading from '$cfgfile'\n";
my ($yaml, $arrayref, $string) = YAML::LoadFile($cfgfile);

# grok schema
my $schema = $yaml->{schema};
# $schema->{fields} = mapzip($schema->{fields}, ["name", "types", "units", "description"]);
$schema->{tags} = splittags($schema->{tags});

my %dataset;
$dataset{infochimp_head} = $schema;

# get source file
$dataset{infochimp_payload} = grokfile($schema, $yaml->{sourceinfo});

# &dump_Dumper(\%dataset);
&dump_XML(\%dataset);
&dump_YAML(\%dataset);
