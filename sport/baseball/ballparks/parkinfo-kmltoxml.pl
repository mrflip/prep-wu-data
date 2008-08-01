#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;


sub walk_kml_folders($) {
    my $kml        = shift;
    my $placemarks = $kml->{Placemark} || [];

    for my $subfolder (@{$kml->{Document}||[]}) {
	push @$placemarks, @{ &walk_kml_folders($subfolder) };
    }
    for my $subfolder (@{$kml->{Folder}||[]}) {
	push @$placemarks, @{ &walk_kml_folders($subfolder) };
    }
    return $placemarks;
}


#
# Import park locations from a google earth .kml file (.kml has XML format)
#
sub import_park_locations($) {
    my $kmlfilename = shift;
    my $xmlw = XML::Simple->new(KeyAttr=>[], ForceContent=>0,
				ForceArray => ['Document', 'Folder', 'Placemark'],
				RootName => 'parks', GroupTags => {Teams => 'parks'},
				);
    my $parksxml = $xmlw->XMLin($kmlfilename);

    # Make a park for each placemark
    my @parks_loc   = ();
    my @placemarks  = @{ &walk_kml_folders($parksxml) };
    for my $parkxml (@placemarks) {
	my $park = {};
	my $view = $parkxml->{LookAt} || $parkxml->{View};

	$park->{lat}	= $view->{latitude};
	$park->{lng}	= $view->{longitude};
	$park->{range}	= $view->{range};
	$park->{parkyearname}   = $parkxml->{name};
	$park->{parkyearname}   =~ tr/\x20-\x7f//cd;
	# $park->{description} = $parkxml->{description} || '';

	# parse CDATA from description
	# my %happytags = (span=>'class', p=>'class', div=>'class', a=>'class');
	# $park->{description} = XMLin("<foo>".$parkxml->{description}."</foo>",
	# 			     ForceContent=>0, ContentKey => '-content',
	# 			     KeyAttr=>\%happytags, ForceArray => [keys %happytags, 'td', 'tr'],);

        push @parks_loc, $park;
    }
    # print Dumper(\@parks_loc);
    return \@parks_loc;
}


sub fix_park_locations($$) {
    my $parks     = shift;
    my $parks_loc = shift;
    (my ($namemap, $dupemap)) = get_namemap($parks);

    # pull park names from the data tree
    for my $park (@$parks_loc) {
	$park->{parkyearname} =~ s/- Proposed/0000-Proposed/o;
	$park->{parkyearname} =~ m/^([\/\'\w\-\s\(\)\.]+?)\s+([\d,]+)\s*(?:-\s*([\d,]+|Present|unknown|Proposed))?\s*,\s*([\&\;\'\.\w\s\-\(\),]+?)\s*$/o or 
	    do { warn "Bad match: $park->{parkyearname}"; next; };
	@{$park}{('team', 'beg_kml', 'end_kml', 'name')} = ($1, $2, $3||'', $4);

	# canonicalize name
	$park->{parkID} = $namemap->{&fixname($park->{name})} || '!!!!!';
    }
    
    @$parks_loc = sort {($a->{parkID} cmp $b->{parkID}) || ($a->{name} cmp $b->{name})} @$parks_loc;
    
    for my $park (@$parks_loc) {
	printf "%-46s ---- %8s-%-8s ---- %-40s -- %-40s\n", 
    		$park->{team}, $park->{beg_kml}, $park->{end_kml}, $park->{name}, $park->{parkID};
    }
    
    # NY4:'St. George Cricket Grounds'   =>'SAI01', 		
    # PRO:'Messer Street Grounds'        =>'PRO02', 		
    # HAR:'Hartford Ball Club Grounds'   =>'HRT01
    # SLU:'Union Grounds		 =>'STL04', 					
    # SR2:'Star Park II'                 =>'SYR02', 		
    # TRN:'Troy Ball Club Grounds'       =>'WAT01
    # BFN:'Riverside Grounds             =>'BUF01', 		
    # TRO:'Haymakers' Grounds'           =>'TRO01', 		
    # TRN:'Putnam Grounds'               =>'TRO02', 		

}

# my $parks_loc = &import_park_locations('parkinfo-locations.kml');
my $parks_loc = &import_park_locations('parkinfo-locations-all.kml');

# pull in current ballpark info
my $xml = XML::Simple->new(RootName => 'parks', GroupTags => {Teams => 'parks'});
my $parks = $xml->XMLin('parkinfo-all.xml',  
			ForceArray => ['park', 'team', 'name', 'comment'],
			KeyAttr=>{park=>'parkID', name=>'name'});
fix_park_locations($parks, $parks_loc);


my $xmlw = XML::Simple->new(RootName => 'parks', GroupTags => {parks => 'park'}, 
			    OutputFile => 'parkinfo-locations-flatall.xml',  'SuppressEmpty'=>undef,
			    ForceArray => ['park', 'team', 'name', 'comment'],
			    KeyAttr=>{park=>'parkID', name=>'name'});
$xmlw->XMLout({park=>$parks_loc});

#
# Map names to parkIDs
#
sub fixname($) { local $_ = lc shift; $_ =~ tr/A-Za-z0-9 ()//cd; return $_; }
sub get_namemap(\%) {
    my $parks = shift;
    # these are parks with weird or duplicate or differing names between BDB and other vs. retrosheet
    my %dupemap =
	(
	 );
    my %namemap = (
		   '' => '!!!!'
		   );
    for my $parkID (keys %{$parks->{park}}) {
	for my $name (keys %{$parks->{park}{$parkID}->{name}}) {
	    $namemap{&fixname($name)} = $parkID;
	}
	# $namemap{&fixname($parks->{park}{$parkID}->{currname})} = $parkID;
    }
    return (\%namemap, \%dupemap);
}

