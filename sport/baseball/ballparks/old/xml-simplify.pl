#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use File::Basename;

for my $filename (@ARGV) {

    (my ($basename, $dirname, $suffix)) = fileparse($filename, '(\..*)$');
    my $outfilename  = $dirname.$basename.'-cleaned'.$suffix;
    my $dumpfilename = '/tmp/'.$basename.'-dump'.$suffix;
    printf "%s flattened into %s (and Data::Dumper'ed into %s)\n", $filename, $outfilename, $dumpfilename;

    my $xmldecl = qq{<?xml version='1.0' standalone='yes'?>\n<?xml-stylesheet href="mysql-flat.xsl" type="text/xsl"?>};
    my $xmlw = XML::Simple->new(OutputFile => $outfilename,  
				XMLDecl => $xmldecl,
				ForceContent=>1, ContentKey => 'content', SuppressEmpty=>"", 
				KeepRoot => 0, RootName => 'rows',
				ForceArray =>['row', 'field'], 
				KeyAttr    =>{field=>'name'});
    
    my $xmldata = $xmlw->XMLin($filename);

    for my $row (@{$xmldata->{row}}) {
	$row = $row->{field};
	for my $el (keys %$row) {
	    next unless ( (scalar keys %{$row->{$el}}) == 1);
	    my $key = (keys %{$row->{$el}})[0];
	    if    ($key eq 'content') {
		$row->{$el} = $row->{$el}->{content};
	    }
	    elsif ($key eq 'xsi:nil') {
		$row->{$el} = "";
	    }
	}
    }

    $xmlw->XMLout($xmldata);
    open  DUMPFILE, ">$dumpfilename" or die "Can't open $dumpfilename for writing: $!";
    print DUMPFILE Dumper($xmldata);
    close DUMPFILE;
}
