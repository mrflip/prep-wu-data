#!/usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1;
use XML::Simple qw(:strict);
use Text::CSV_XS;
use IO::File;


#
# To get park info, run these SQL queries and save as XML:
#
# -- BDB info
# SELECT T.teamID, T.teamIDBR, T.teamIDlahman45, T.teamIDretro
#   ,	T.franchID, F.franchName, F.active, F.NAassoc
#   ,	T.lgID, T.divID
#   ,	MIN(T.yearID) AS beg, MAX(T.yearID) AS end
#   ,	COUNT(*) AS tenure
#   ,	T.name, T.park
# FROM		vizsagedb_baseballdatabank.Teams T
# LEFT JOIN	vizsagedb_baseballdatabank .TeamsFranchises F ON (T.franchID = F.franchID)
# GROUP BY T.teamIDretro, T.park
# ORDER BY T.teamIDretro, T.park DESC, beg
#
# -- Gamelog info
# SELECT G.park_ID      AS parkID
#   ,    G.h_team	AS teamID
#   ,    MIN(G.date)	AS Gtenancy_beg
#   ,    MAX(G.date)	AS Gtenancy_end
#   ,    COUNT(*)	AS games_seasons
#   FROM	    vizsagedb_retrosheet.GamesFlat	G
#   GROUP BY  G.h_team, G.park_ID
#   ORDER BY  G.h_team, Gtenancy_beg, G.park_ID
#

#
# Import park locations from a google earth .kml file (.kml has XML format)
#
sub import_park_locations() {
    # http://bbs.keyhole.com/ubb/download.php?Number=721289		NL
    # http://bbs.keyhole.com/ubb/download.php?Number=721294		AL
    # http://bbs.keyhole.com/ubb/placemarks/695305-NLBallparks.kmz	Those two together?
    # http://bbs.keyhole.com/ubb/download.php?Number=47579		AAA Stadiums
    # http://bbs.keyhole.com/ubb/download.php?Number=12353		Football
    # http://bbs.keyhole.com/ubb/placemarks/997756-minorleague.kmz      Minor League

    my $parksxml = XMLin('parkinfo-locations-current30.kml', KeyAttr=>[], ForceContent=>0,
			 ForceArray => ['Folder', 'Placemark']);
    my %parks_loc      = ();
    my @placemarks = ();
    # Parks live in the second folder down.
    for my $folderxml (@{$parksxml->{Document}->{Folder}[0]->{Folder}}) {
	for my $parkxml (@{$folderxml->{Placemark}}) {
	    push @placemarks, $parkxml;
	}
    }
    # Make a park for each placemark
    for my $parkxml (@placemarks) {
	my $park = {};
	my $view = $parkxml->{LookAt} || $parkxml->{View};
	$park->{lat}	= $view->{latitude};
	$park->{lng}	= $view->{longitude};
	$park->{range}	= $view->{range};

	# parse CDATA from description
	my %happytags = (span=>'class', p=>'class', div=>'class', a=>'class');
	$park->{description} = XMLin("<foo>".$parkxml->{description}."</foo>",
				     ForceContent=>0, ContentKey => '-content',
				     KeyAttr=>\%happytags, ForceArray => [keys %happytags, 'td', 'tr'],);
	$parks_loc{$parkxml->{name}} = $park;
    }
    return \%parks_loc;
}

#
# Snarf XML from each source to merge.
#
sub import_parks() {
    my %parks_in = ();
    $parks_in{bdb}       = XMLin('parkinfo-bdb.xml'               , SuppressEmpty=>'', KeyAttr=>[], ForceArray => []);
    $parks_in{rshtml}    = XMLin('parkinfo-rshtml.xml'            , SuppressEmpty=>'', KeyAttr=>[], ForceArray => ['team', 'name']);
    $parks_in{parkcode}  = XMLin('parkinfo-parkcodes.xml'         , SuppressEmpty=>'', KeyAttr=>[], ForceArray => []);
    $parks_in{gamelogs}  = XMLin('parkinfo-gamelogs.xml'          , SuppressEmpty=>'', KeyAttr=>[], ForceArray => []);
    $parks_in{mlb}       = XMLin('parkinfo-mlb.xml'               , SuppressEmpty=>'', KeyAttr=>[], ForceArray => []);
    $parks_in{neut}      = XMLin('parkinfo-neutralgames-comments-cleaned.xml', SuppressEmpty=>'', KeyAttr=>[], ForceArray => ['row']);
    $parks_in{loc} = &import_park_locations();
    return \%parks_in
}

sub save_park_arrfield($$$) {
    (my ($park, $field, $val)) = @_;
    $park->{$field} = $park->{$field} || [];
    push @{$park->{$field}}, $val;
}

sub save_park_hashfield($$$$) {
    (my ($park, $field, $key, $valsin)) = @_;
    # make the hashes exist
    if (! $park->{$field} ) { $park->{$field} = {}; };
    my %valsin = %$valsin;
    my %vals   = %{$park->{$field}{$key}||{}};
    # slice the new values in
    @vals{keys %valsin} = @valsin{keys %valsin};
    $park->{$field}{$key} = \%vals;
}

#
# records of each (team, park) that has a gamelog
#
sub merge_gamelogs(\%\%\%\%) {
    my $parks   = shift;
    my $parksin = shift;

    # flat array
    for my $parkteamin (@{$parksin->{parkteam}}) {
	my $parkID = $parkteamin->{parkID};
	my $parkteam   = $parks->{park}{$parkID} || {};
	# Strip it for parts
	&save_park_hashfield($parkteam, 'team', $parkteamin->{teamID}, {
	    teamID   => $parkteamin->{teamID},
	    games    => $parkteamin->{games_seasons},
	    beg      => $parkteamin->{beg}, end => $parkteamin->{end},
	});
	# save it
	$parks->{park}{$parkID} = $parkteam;
    }

    # flat array
    for my $parkin (@{$parksin->{park}}) {
	my $parkID = $parkin->{parkID};
	my $park   = $parks->{park}{$parkID} || {};
	# Strip it for parts
	$park->{beg}   = $parkin->{beg}, 
	$park->{end}   = $parkin->{end}, 
	$park->{games} = $parkin->{games}, 
	# save it
	$parks->{park}{$parkID} = $park;
    }
}


sub merge_neut(\%\%) {
    my $parks    = shift;
    my $parksin = shift;
 
    # flat array
    for my $parkin (@{$parksin->{row}}) {
	my $parkID = $parkin->{parkID};
	my $park   = $parks->{park}{$parkID} || {};
	# Strip it for parts
	my $comment = $parkin->{neutralsite_comment};
	&save_park_hashfield($park, 'comment', lc $comment, {parkID=>$parkID, comment=>$comment});
	$park->{team}->{$parkin->{teamID}}->{neutralsite} = 1;
	# save it
	$parks->{park}{$parkID} = $park;
    }
}



#
# Address and URL info scraped from MLB.com
#
sub merge_mlb(\%\%) {
    my $parks	= shift;
    my $namemap = shift;
    my $dupemap = shift;
    my $parksin = shift;

    # gamelog-derived info comes in keyed as team-park
    for my $parkin (@{$parksin->{team}}) {
	# identify park
	my $parkname = $parkin->{parkname};
	my $parkID = $namemap->{&fixname($parkname)}||'' or do { print "Didn't find name $parkname in mlb\n";  };
	my $park   = $parks->{park}{$parkID} || {};

	# Strip it for parts
	# $park->{teamname_mlb}	= $parkin->{name};
	# $park->{parkname_mlb}	= $parkin->{parkname};
	$park->{extaddr}	= $parkin->{extaddr};
	$park->{streetaddr}	= $parkin->{streetaddr};
	# $park->{city_mlb}	= $parkin->{city};
	# $park->{state_mlb}	= $parkin->{state};
	# $park->{country_mlb}	= $parkin->{country};
	$park->{zip}		= $parkin->{zip};
	$park->{tel}		= $parkin->{tel};
	$park->{url}		= $parkin->{url};
	$park->{spanishurl}	= $parkin->{spanishurl};
	$park->{logofile}	= $parkin->{logofile};
	$park->{active}   	  = 1;

	&save_park_hashfield($park, 'othername', &fixname($parkin->{parkname}), {name => $parkin->{parkname} });
	$park->{othername}->{&fixname($parkin->{parkname})}->{auth} = 0 unless $park->{othername}->{&fixname($parkin->{parkname})}->{auth};

	# save it
	$parks->{park}{$parkID} = $park;
    }
}

#
# RS screenscraped HTML comes in grouped by park/team but has funny team/franchise IDs
#
sub merge_rshtml(\%\%) {
    my $parks   = shift;
    my $parksin = shift;

    # RS screenscraped HTML comes in grouped by park/team but has funny team/franchise IDs
    for my $parkin (@{$parksin->{park}}) {
	# identify park
	my $parkID = $parkin->{parkID};
	my $park   = $parks->{park}{$parkID} || {};

	# Strip it for parts
	# $park->{beg_rsh}     	= $parkin->{beg}.'-00-00'   ;
	# $park->{end_rsh}     	= $parkin->{end}.'-00-00'   ;
	$park->{city}     	= $parkin->{city}  ;
	$park->{state}          = $parkin->{state} ;
	$park->{country}        = 'US' unless $park->{country};		# this will be fixed in &extra_fixins
	$park->{name}           = $parkin->{currname}  ;
	for my $name (@{$parkin->{name}}) {
	    &save_park_hashfield($park, 'othername', &fixname($name->{name}),
				{name  => $name->{name}, 
				 beg => $name->{beg},  end  => $name->{end},
				 auth  => 1, curr => 0, 
				 });
	}
	&save_park_hashfield($park, 'othername', &fixname($parkin->{currname}),
			     {name     => $parkin->{currname}, auth => 1, curr=>1, });

	# this breaks on MIL and other teams that switch leagues but not names.
	for my $teamin (@{$parkin->{team}}) {
	    &save_park_hashfield($park, 'team', $teamin->{team},
				 {teamID    => $teamin->{team}, 
				  # franchID_rsh => $teamin->{franch}, lgID_rsh  => $teamin->{lg},
			      });
	    my $team = $park->{team}->{$teamin->{team}};
	    # $team->{beg_rsh}       = $teamin->{beg} if ( (!exists $team->{beg_rsh}) || ($teamin->{beg} < $team->{beg_rsh}) );
	    # $team->{end_rsh}       = $teamin->{end} if ( (!exists $team->{end_rsh}) || ($teamin->{end} > $team->{end_rsh}) );
	}


	# save it
	$parks->{park}{$parkID} = $park;
    }
}

#
# records from a slightly obsolete parkcodes file
#
sub merge_parkcodes(\%\%) {
    my $parks   = shift;
    my $parks_parkcode = shift;

    # parkcodes info comes in as canonical parks
    # with messy name/team info
    # but missing a couple
    for my $parkin (@{$parks_parkcode->{park}}) {
	my $parkID = $parkin->{parkID};
	my $park   = $parks->{park}{$parkID};

	# $park->{city_pc}  = $parkin->{city}     if exists $parkin->{city}    ;
	# $park->{state_pc} = $parkin->{state}    if exists $parkin->{state}   ;
	# $park->{beg_pc}  = $parkin->{start}    if exists $parkin->{start}   ;
	# $park->{end_pc}  = $parkin->{end}      if exists $parkin->{end}     ;
	# $park->{lgID_pc}  = $parkin->{leagueID} if exists $parkin->{leagueID};

	if ($parkin->{comment}) {
	    my @comments = split ';\s*', $parkin->{comment};
	    for my $comment (@comments) {
		&save_park_hashfield($park, 'comment', &fixname($comment), {parkID=>$parkID, comment=>$comment});
	    }
	}
	if ($parkin->{name}) {
	    &save_park_hashfield($park, 'othername', &fixname($parkin->{name}), {name=>$parkin->{name} });
	    $park->{othername}->{&fixname($parkin->{name})}->{auth} = 0 unless $park->{othername}->{&fixname($parkin->{name})}->{auth};
	}
	if ($parkin->{aka}) {
	    my @names = split ';\s*', $parkin->{aka};
	    for my $name (@names) {
		&save_park_hashfield($park, 'othername', &fixname($name), {name=>$name });
		$park->{othername}->{&fixname($name)}->{auth} = 0 unless $park->{othername}->{&fixname($name)}->{auth};
	    }
	}
	$parks->{park}{$parkID} = $park;
    }
}

sub merge_loc(\%\%) {
    my $parks     = shift;
    my $namemap   = shift;
    my $dupemap   = shift;
    my $parks_loc = shift;

    my $parks_loc_more = XMLin('parkinfo-locations-flatall.xml' , SuppressEmpty=>'', KeyAttr=>{park=>'parkID'}, ForceArray => ['park']);
  
    for my $parkID (keys %{$parks_loc_more->{park}}) {
	# look up park by name (no ID's in parkloc yet)
	my $parkin = $parks_loc_more->{park}->{$parkID};
	my $park   = $parks->{park}{$parkID} || {};
	# basic fields
	$park->{lat}	     = $parkin->{lat};
	$park->{lng}	     = $parkin->{lng};
	$parks->{park}{$parkID} = $park;
    }

    # googleearth-derived info should comes in highly structured
    for my $parkname (keys %$parks_loc) {
	my $parkin = $parks_loc->{$parkname};

	# look up park by name (no ID's in parkloc yet)
	my $parkID = $namemap->{&fixname($parkname)};
	if (! exists $namemap->{&fixname($parkname)}) { print "Didn't find name $parkname in loc\n";  }
	my $park   = $parks->{park}{$parkID} || {};

	# basic fields
	$park->{lat}	     = $parkin->{lat};
	$park->{lng}	     = $parkin->{lng};
	# $park->{range}	     = $parkin->{range};
	my $description      = $parkin->{description};

	# dismantle source hash so we can see how we're doing
	sub parse_desc(\%\%\@) {
	    my $dest   = shift;
	    my $obj = shift;
	    my $fields = shift;
	    for my $field (@$fields) {
		next unless exists $obj->{$field};
		my $val = $obj->{$field};
		if ((ref $val eq 'HASH') && ((join '',keys %$val) eq 'content')) { $val = $val->{content}; }
		$dest->{$field}  = $val;
		delete             $obj->{$field};
	    }
	}
	# &parse_desc($park, $description->{a}{"fn org url"}, [qw{href}]);
	# $park->{name_loc} = $description->{a}{"fn org url"}->{content} if exists $description->{a}{"fn org url"}->{content};
	&parse_desc($park, $description->{span}{loc}{span}, [qw{street-address locality region postal-code country-name tel}]);
	&parse_desc($park, $description->{span},            [qw{parkID}]);
	&parse_desc({},    $description->{div},             [qw{parkdims}]);

	$parks->{park}{$parkID} = $park;
    }
}

# BDB info comes in grouped by team/year.
# pivot it to park / team / tenure
sub merge_bdb(\%\%) {
    my $parks     = shift;
    my $namemap   = shift;
    my $dupemap   = shift;
    my $teamsin   = shift;

    my $fh  = new IO::File;
    $fh->open(">parkinfo-bdbnames.txt") or die "Can't write to parkinfo-bdbnames.txt: $!";

    for my $teamin (@{$teamsin->{Teams}}) {
	# identify park
	my @parknames = ('',);
	@parknames = split /\s*\/\s*/, ($teamin->{park}) if exists $teamin->{park};
	for my $parkname (@parknames) {
	    # identify the team
	    my $teamID = $teamin->{teamIDretro};
	    next if ($teamID eq 'SPU'); 	# this team played no home games, ever.
	    $teamID =~ s/^ALA$/ANA/;    	# BDB wants to change its teamID... change it back.

	    # identify park from its name.
	    my $parkID;
	    $parkID = $dupemap->{"$teamID:$parkname"} || $namemap->{&fixname($parkname)} || '';
	    if (!$parkID) { print "Didn't find name '$parkname' using $parkID\n";   }
	    my $park = $parks->{park}{$parkID} || {};

	    # Record the BDB name.
	    if ($parkname ne '') {
		&save_park_hashfield($park, 'othername', &fixname($parkname), {name => $parkname});
		$park->{othername}->{&fixname($parkname)}->{auth} = 0 unless $park->{othername}->{&fixname($parkname)}->{auth};
	    }
		
	    # Dump the BDB mapping to a file.
	    printf $fh "'%-3s:%-40s =>'%5s', # %s\n", $teamin->{teamIDretro}, "$parkname'", $parkID, 
	    		($park->{name} eq $parkname ? "" : 
			 sprintf "# %-40s %s\n", $park->{name}, "$teamin->{teamIDretro} park from $teamin->{beg} to $teamin->{end}");

	    # Strip it for parts
	    my $team = $park->{team}->{$teamID}||{};
	    $team->{teamID}         = $teamID;
	    # $team->{teamname}       = $teamin->{name};
	    # $team->{teamIDBDB}      = $teamin->{teamID}        ;
	    # $team->{teamIDBR}       = $teamin->{teamIDBR}      ;
	    # $team->{teamIDlahman45} = $teamin->{teamIDlahman45};
	    # $team->{franchID_bdb}   = $teamin->{franchID}      ;
	    # $team->{franchName}     = $teamin->{franchName}    ;
	    # $team->{lgID_bdb}       = $teamin->{lgID}          ;
	    # $team->{beg_bdb}        = $teamin->{beg} if ( (!exists $team->{beg_bdb}) || ($teamin->{beg} < $team->{beg_bdb}) );
	    # $team->{end_bdb}        = $teamin->{end} if ( (!exists $team->{end_bdb}) || ($teamin->{end} > $team->{end_bdb}) );
	    $team->{parknameBDB}    = $teamID.":".$parkname; # ":".$team->{beg_bdb}."-".$team->{end_bdb}.

	    &save_park_hashfield($park, 'team', $teamID, $team);

	    # Save it
	    $parks->{park}{$parkID} = $park;
	}
    }
    close $fh;
}

sub unifyfields($$) {
    (my ($obj, $fields)) = @_;
    my %obj = %$obj;
    my $ok  = 1;
    my $val = $obj->{$fields->[0]};
    for my $field (@$fields) {
	$ok = ($val eq $obj{$field}) or last;
    }
    if (!$ok) {
	printf "Bad juju in %s -- got %s\n", (join ',',@$fields), (join ',',@obj{@$fields});
    }
}


sub extra_fixins(\%) {
    my $parks     = shift;

    # stuff in international info
    @{$parks->{park}->{'MNT01'}}{('state','country')} = ('NL', 'MX');			# http://www.statoids.com/umx.html
    @{$parks->{park}->{'SJU01'}}{('state','country')} = ('PR', 'US');			# Should this be SJ, PR? Anyway, it JOINs with my Zip database http://www.statoids.com/upr.html
    @{$parks->{park}->{'MON01'}}{('state','country')} = ('QC', 'CA');			# Quebec, Canada    	http://www.statoids.com/uca.html
    @{$parks->{park}->{'MON02'}}{('state','country')} = ('QC', 'CA');			# Quebec, Canada    	http://www.statoids.com/uca.html
    @{$parks->{park}->{'TOR01'}}{('state','country')} = ('ON', 'CA');			# Ontario, Canada   	http://www.statoids.com/uca.html
    @{$parks->{park}->{'TOR02'}}{('state','country')} = ('ON', 'CA');			# Ontario, Canada   	http://www.statoids.com/uca.html
    @{$parks->{park}->{'TOK01'}}{('state','country')} = ('TK', 'JP');			# Tokyo, Japan 	  	http://www.statoids.com/ujp.html

    # These had inconsistent city/state infor
    @{$parks->{park}->{'ALB02'}}{('city','state')} = ('Rensselaer'	, 'NY');	# 12144         City then known as Greenbush http://en.wikipedia.org/wiki/Rensselaer%2C_NY
    @{$parks->{park}->{'NYC07'}}{('city','state')} = ('Brooklyn'	, 'NY');	# 		parkcodes had city as 'Ridgewood' (zips 11385/86)
    @{$parks->{park}->{'NYC16'}}{('city','state')} = ('Bronx'		, 'NY');	#  		This is what the Post office calls it
    @{$parks->{park}->{'NYC17'}}{('city','state')} = ('Flushing'	, 'NY');	#  		This is what the Post office calls it
    @{$parks->{park}->{'NYC18'}}{('city','state')} = ('Brooklyn'	, 'NY');	# 		parkcodes had city as 'Ridgewood' (zips 11385/86) 
    @{$parks->{park}->{'STL10'}}{('city','state')} = ('Saint Louis'	, 'MO');	#  		This is what the Post office calls it
    @{$parks->{park}->{'STP01'}}{('city','state')} = ('Saint Petersburg', 'FL');	# 		This is what the Post office calls it
    @{$parks->{park}->{'WAT01'}}{('city','state')} = ('Watervliet'	, 'NY');	# 12189		City then known as West Troy http://en.wikipedia.org/wiki/Watervliet%2C_New_York

    # These fail matches against the zip code DB and so we'll add the lat_approx, lng_approx and zip (if unique) by hand
    @{$parks->{park}->{'IRO01'}}{('city',     )} = ('Rochester'     ,     );	# 12144         City then known as Greenbush http://en.wikipedia.org/wiki/Rensselaer%2C_NY
    @{$parks->{park}->{'LUD01'}}{('city','zip')} = ('Covington'     ,41016);	# 		parkcodes had city as 'Ridgewood' (zips 11385/86)
    @{$parks->{park}->{'MIN02'}}{('city',     )} = ('Minneapolis'   ,     );	#  		This is what the Post office calls it
    @{$parks->{park}->{'GEA01'}}{('city','zip')} = ('Aurora'	    ,44202);	#  		This is what the Post office calls it
    @{$parks->{park}->{'CLL01'}}{('city','zip')} = ('Cleveland'     ,44110);	# 		parkcodes had city as 'Ridgewood' (zips 11385/86) 
    @{$parks->{park}->{'PEN01'}}{('city','zip')} = ('Cincinnati'    ,45226);	#  		This is what the Post office calls it
    @{$parks->{park}->{'SAI01'}}{('city',     )} = ('Staten Island' ,     );	# 		This is what the Post office calls it
    @{$parks->{park}->{'THR01'}}{('city','zip')} = ('Clay'	    ,13041);	# 12189		City then known as West Troy http://en.wikipedia.org/wiki/Watervliet%2C_New_York
    @{$parks->{park}->{'WAV01'}}{('city','zip')} = ('Newark'	    ,07112);	# 		This is what the Post office calls it

    # These aren't in rshtml and need to be fixed by hand
    $parks->{park}->{'FOR02'} = { parkID=>"FOR02", name=>"Swinney Park",  
				  city=>"Fort Wayne",       state=>"IN", country=>"US",            beg=>"1882-10-24", end=>"1882-10-24", 
				  comment =>{ c1=>{parkID=>"FOR02", comment=>"Last game of playoffs (CHN &amp; PRO)"}, 
					      c2=>{parkID=>"FOR02", comment=>"Stadium only found in old parkcodes.txt, data suspect"}, },
				  othername =>{ n1=>{name=>"Swinney Park", curr=>"1", auth=>"1"}, }
			      };
    $parks->{park}->{'SYR04'} = { parkID=>"SYR04", name=>"Lakeside Park", 
				  city=>"Syracuse",          state=>"NY", country=>"US",           beg=>"1879-05-31", end=>"1879-08-09", 
				  comment =>{ c1=>{parkID=>"SYR04", comment=>"SR1: Sundays", },
					      c2=>{parkID=>"SYR04", comment=>"stadium only found in old parkcodes.txt, data suspect", } },
				  othername =>{ n1=>{auth=>"1", curr=>"1", name=>"Lakeside Park", } },
			      };
    my $excomment = $parks->{park}->{'LBV01'}->{comment}; 
    $parks->{park}->{'LBV01'} = { parkID=>"LBV01", name=>"The Ballpark at Disney's Wide World of Sports",  games=>3,
				  city=>"Lake Buena Vista", state=>"FL", country=>"US", zip=>"32830", beg=>"2007-05-15", end=>"2007-05-17", 
				  comment =>$excomment,
				  othername =>{ n1=>{auth=>"1", curr=>"1", name=>"The Ballpark at Disney's Wide World of Sports", }  },
				  team    =>{ t1=>{teamID=>"TBA", beg=>"2007-05-15", end=>"2007-05-17", games=>"3", teamname=>"Tampa Bay Devil Rays", neutralsite=>1 } },
			      };

    $parks->{park}->{'BOS09'} = { parkID=>"BOS09", name=>"Proposed Boston Red Sox Park",  games=>0,
				  city=>"Boston", state=>"MA", country=>"US", zip=>"02215", beg=>"NULL", end=>"NULL", 
				  comment =>{ c1=>{parkID=>"BOS09", comment=>"Proposed (but not currently planned) Boston Red Sox Park: All info suspect"}, },
				  othername =>{ n1=>{auth=>"1", curr=>"0", name=>"Proposed Boston Red Sox Park", }  },
				  team    =>{ t1=>{teamID=>"BOS", beg=>"NULL", end=>"NULL", games=>"0", teamname=>"Boston Red Sox", } },
			      };

    $parks->{park}->{'MIN04'} = { parkID=>"MIN04", name=>"Proposed Minnesota Twins Park",  games=>0,
				  city=>"Minneapolis", state=>"MN", country=>"US", zip=>"", beg=>"NULL", end=>"NULL", 
				  comment =>{ c1=>{parkID=>"MIN04", comment=>"Proposed Minnesota Twins Park"}, },
				  othername =>{ n1=>{auth=>"1", curr=>"0", name=>"Proposed Minnesota Twins Park", }  },
				  team    =>{ t1=>{teamID=>"MIN", beg=>"NULL", end=>"NULL", games=>"0", teamname=>"Minnesota Twins", } },
			      };

    $parks->{park}->{'NYC19'} = { parkID=>"NYC19", name=>"Proposed New York Yankees Park",  games=>0,
				  city=>"New York", state=>"NY", country=>"US", zip=>"", beg=>"NULL", end=>"NULL", 
				  comment =>{ c1=>{parkID=>"NYC19", comment=>"Proposed New York Yankees Park"}, },
				  othername =>{ n1=>{auth=>"1", curr=>"0", name=>"Proposed New York Yankees Park", }  },
				  team    =>{ t1=>{teamID=>"NYA", beg=>"NULL", end=>"NULL", games=>"0", teamname=>"New York Yankees", } },
			      };

    $parks->{park}->{'OAK02'} = { parkID=>"OAK02", name=>"Proposed Oakland Athletics Stadium",  games=>0,
				  city=>"Oakland", state=>"CA", country=>"US", zip=>"", beg=>"NULL", end=>"NULL", 
				  comment =>{ c1=>{parkID=>"OAK02", comment=>"Proposed Oakland Athletics Stadium"}, },
				  othername =>{ n1=>{auth=>"1", curr=>"0", name=>"Proposed Oakland Athletics Stadium", }  },
				  team    =>{ t1=>{teamID=>"OAK", beg=>"NULL", end=>"NULL", games=>"0", teamname=>"Oakland Athletics", } },
			      };

    # stuff in other names
    &save_park_hashfield($parks->{park}->{'PEN01'}, 'othername', &fixname('East End Park'), {name => 'East End Park'});  # http://en.wikipedia.org/wiki/Pendleton_Park

    &save_park_hashfield($parks->{park}->{'MIL06'}, 'team', 'CLE', {teamID=>'CLE', games=>3, beg=>'2007-04-10', end=>'2007-04-12', }); 
    &save_park_hashfield($parks->{park}->{'CHI10'}, 'team', 'CHN', {teamID=>'CHN', games=>3, beg=>'1918-09-05', end=>'1918-09-07', }); 

    # current parks shouldn't really have an end date.  Fudge this in.
    for my $park (values %{$parks->{park}}) {
	$park->{end} = '9999-12-31' 	if (($park->{end} =~ m/200[67]-\d\d-\d\d/) 	&& $park->{active});
	for my $team (values %{$park->{team}}) {
	    $team->{end} = '9999-12-31'	if (($team->{end} =~ m/200[67]-\d\d-\d\d/)	&& $park->{active});
	}
	for my $name (values %{$park->{othername}}) {
	    $name->{end} = '9999'	if ((defined $name->{end}) && ($name->{end} =~ m/200[67]/) && $park->{active});
	}
    }

    # Make non-altsites 0, not NULL
    for my $park (values %{$parks->{park}}) {
	for my $team (values %{$park->{team}}) {
	    $team->{neutralsite} = 0	if (! $team->{neutralsite});
	}
    }




}

my %parks = ();
my $parks_in = &import_parks();
&merge_gamelogs  (\%parks, $parks_in->{gamelogs});
&merge_parkcodes (\%parks, $parks_in->{parkcode});
&merge_rshtml    (\%parks, $parks_in->{rshtml});
my ($namemap, $dupemap) = &get_namemap (\%parks);
# print Dumper($namemap);
&merge_loc       (\%parks, $namemap, $dupemap, $parks_in->{loc});
&merge_bdb       (\%parks, $namemap, $dupemap, $parks_in->{bdb});
&merge_mlb       (\%parks, $namemap, $dupemap, $parks_in->{mlb});
&merge_neut      (\%parks, $parks_in->{neut});

&extra_fixins    (\%parks);

# print Dumper(\%parks);
my $xmldecl = qq{<?xml version='1.0' standalone='yes'?>\n<?xml-stylesheet href="parkinfo-all.xsl" type="text/xsl"?>};
my $xmlw = XML::Simple->new(RootName => 'parks', GroupTags => {Teams => 'parks'},  
			    KeyAttr=>{park=>'parkID', team=>'teamID', othername=>'name', comment=>'parkID'}, 
			    ForceArray=>['park', 'team', 'othername', 'comment']);
$xmlw->XMLout(\%parks,      OutputFile => 'parkinfo-all.xml');

#
# Map names to parkIDs
#
sub fixname($) { local $_ = lc shift; $_ =~ tr/A-Za-z0-9 ()//cd; return $_; }
sub get_namemap(\%) {
    my $parks = shift;
    # these are parks with weird or duplicate or differing names between BDB and other vs. retrosheet
    my %dupemap =
	(
	'ALA:Angel Stadium'				=>'ANA01',
	'ANA:Angel Stadium'				=>'ANA01',
	'ANA:Angels Stadium of Anaheim'			=>'ANA01',
	'ANA:Edison International Field'		=>'ANA01',
	'BFN:Riverside Park'                            =>'BUF01',
	'BL1:Olympics Grounds'				=>'WAS01',
	'BL2:Oriole Park'				=>'BAL03',
	'BL3:Oriole Park'				=>'BAL06',
	'BL3:Union Park'				=>'BAL07',
	'BL4:Newington Park'                            =>'BAL01',
	'BLA:Oriole Park'				=>'BAL09',
	'BLN:Union Park'				=>'BAL07',
	'BOS:Fenway Park I'				=>'BOS07',
	'BOS:Fenway Park II'				=>'BOS07',
	'BOS:Huntington Avenue Grounds'			=>'BOS06',
	'BR1:Union Grounds'				=>'NYC01',
	'BR2:Union Grounds'				=>'NYC01',
	'BR4:Ridgewood Park'				=>'NYC18',
	'BSN:Fenway Park I'				=>'BOS07',
	'CH1:Union Base-Ball Grounds'			=>'CHI01',
	'CHN:Union Base-Ball Grounds'			=>'CHI01',
	'CHN:South Side Park I'     			=>'CHI07',
	'CHA:South Side Park II'     			=>'CHI09',
	'CH2:23rd Street Grounds'			=>'CHI02',
	'CHN:23rd Street Grounds'			=>'CHI02',
	'CHA:Comiskey Park'				=>'CHI10',
	'CHA:Comiskey Park'				=>'CHI10',
	'CHA:Comiskey Park II'				=>'CHI12',
	'CHF:Wrigley Field'				=>'CHI11',
	'CHN:Wrigley Field'				=>'CHI11',
        'CHN:West Side Park I'                          =>'CHI06',
        'CHN:West Side Park II'                         =>'CHI08',
        'CHN:Lake Front Park II'                        =>'CHI04',
	'CIN:League Park I in Cincinnati'		=>'CIN04',
	'CIN:League Park II in Cincinnati'		=>'CIN05',
	'CL3:National League Park II'			=>'CLE03',
	'CLP:'                                          =>'CLE04',
	'CL4:League Park I'				=>'CLE05',
	'CL4:National League Park'			=>'CLE03',
	'CL5:Recreation Park I'				=>'COL01',
	'CL6:Recreation Park II'			=>'COL02',
	'CLE:League Park I'				=>'CLE05',
	'CLE:League Park II'				=>'CLE06',
	'CN2:League Park I in Cincinnati'		=>'CIN04',
	'DTN:Recreation Park'				=>'DET01',
	'FW1:Hamilton Field'				=>'FOR01',
	'IN2:Seventh Street Park'			=>'IND02',
	'IN3:Athletic Park I'				=>'IND04',
	'IN3:Athletic Park II'				=>'IND05',
	'KC1:Municipal Stadium I'			=>'KAN05',
	'KC2:Association Park I'			=>'KAN02',
	'KCA:Municipal Stadium II'			=>'KAN05',
	'KCN:Association Park'				=>'KAN02',
	'LAA:Wrigley Field (LA)'			=>'LOS02',
	'ML2:Eclipse Park II'				=>'MIL01',
	'ML3:Athletic Field'				=>'MIL03',
	'MON:Hiram Bithorn Stadium'			=>'SJU01',
	'NH1:Hamilton Park'				=>'NEW01',
	'NY1:Oakdale Park'				=>'JER01',
	'NY1:Polo Grounds I'				=>'NYC03',
	'NY1:Polo Grounds I West Diamond'		=>'NYC03',
	'NY1:Polo Grounds II'				=>'NYC09',
	'NY1:Polo Grounds III'				=>'NYC10',
	'NY1:Polo Grounds IV'				=>'NYC14',
	'NY4:Polo Grounds I West Diamond'		=>'NYC03',
	'NYA:Polo Grounds IV'				=>'NYC14',
	'NYA:Yankee Stadium I'				=>'NYC16',
	'NYA:Yankee Stadium II'				=>'NYC16',
	'NYN:Polo Grounds IV'				=>'NYC14',
	'OAK:Oakland Coliseum'				=>'OAK01',
	'PH3:Centennial Grounds'			=>'PHI02',
	'PH4:Athletic Park'				=>'PHI01',
	'PH4:Oakdale Park'				=>'PHI03',
	'PHA:Columbia Park'				=>'PHI10',
	'PHI:Recreation Park'				=>'PHI04',
	'PIT:Recreation Park'				=>'PIT04',
	'PIT:Exposition Park'				=>'PIT05',
	'PT1:Recreation Park'				=>'PIT04',
	'RIC:Allen Pasture'				=>'RIC02',
	'SL1:Red Stocking Baseball Park'		=>'STL01',
	'SL3:Sportsman\'s Park I'                       =>'STL02',
	'SL4:Sportsman\'s Park I'                       =>'STL03',
	'SL5:Sportsman\'s Park I'                       =>'STL04',
	'SLA:Sportsman\'s Park III'                     =>'STL06',
        'SLA:Sportsman\'s Park IV'                      =>'STL07',
        'SLN:Sportsman\'s Park IV'                      =>'STL07',
	'TEX:The Ballpark at Arlington'			=>'ARL02',
	'TRN:Troy Ball Club Grounds'			=>'WAT01',
	'TL1:League Park'				=>'TOL01',
	'WOR:Worcester Driving Park Grounds'		=>'WOR01',
	'WS1:American League Park I'			=>'WAS07',
	'WS1:Griffith Stadium I'			=>'WAS09',
	'WS1:Griffith Stadium II'			=>'WAS09',
	'WS2:American League Park II'			=>'WAS08',
	'WS2:Griffith Stadium II'			=>'WAS09',
	'WS3:Olympics Grounds'				=>'WAS01',
	'WS4:Nationals Grounds'				=>'WAS02',
	'WS5:Olympics Grounds'				=>'WAS01',
	'WS6:Olympics Grounds'				=>'WAS01',
	'WS7:Athletic Park'				=>'WAS04',
	'WS8:Swampdoodle Grounds'			=>'WAS05',
	'ALT:'						=>'ALT01',
	'BFP:'						=>'BUF03',
	'BLF:'						=>'BAL10',
	'BLU:'						=>'BAL04',
	'BRF:'						=>'NYC12',
	'BRP:'						=>'NYC11',
	'BSP:'						=>'BOS04',
	'BSU:'						=>'BOS02',
	'BUF:'						=>'BUF04',
	'CHP:'						=>'CHI07',
	'CHU:'						=>'CHI05',
	'CLP'						=>'CLE04',
	'CNU:'						=>'CIN03',
	'IND:'						=>'IND07',
	'KCF:'						=>'KAN04',
	'KCU:'						=>'KAN01',
	'MLU:'						=>'MIL02',
	'NEW:'						=>'HAR01',
	'NYP:'						=>'NYC10',
	'PHP:'						=>'PHI07',
	'PHU:'						=>'PHI05',
	'PTF:'						=>'PIT05',
	'PTP:'						=>'PIT05',
	'SLF:'						=>'STL08',
	'SLU:'						=>'STL04',
	'WIL:'						=>'WIL01',
	'WSU:'						=>'WAS03',
	 );
    # 	'SPU:'						=> NULL -- omitted, as it played no home games.
    # SPU -- The club went 2-6-1 in nine road games, earning the distinction of being the only major league team not to play a single home game.
    # http://en.wikipedia.org/wiki/St._Paul_White_Caps
    my %namemap = ('metrodome' => 'MIN03', 'dolphin stadium' => 'MIA01', 'busch stadium' => 'STL10');
    for my $parkID (keys %{$parks->{park}}) {
	for my $name (keys %{$parks->{park}{$parkID}->{othername}}) {
	    $namemap{&fixname($name)} = $parkID;
	}
	# $namemap{&fixname($parks->{park}{$parkID}->{name})} = $parkID;
    }
    return (\%namemap, \%dupemap);
}

