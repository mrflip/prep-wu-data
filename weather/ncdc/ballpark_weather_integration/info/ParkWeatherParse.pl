#!/usr/bin/perl -w

use strict;
use Data::Dumper;
use XML::Simple;
use List::Util qw{reduce};

sub getParkLocations() {
    my $parksxml = XMLin('/home/flip/now/Weather/ParkLocations.kml.xml', ForceContent=>1);

    my %parks = ();
    for my $parkxml (@{$parksxml->{Placemark}}) {
	#print Dumper($parkxml);
	my $park = {};
	$park->{name}	= $parkxml->{name}->{content};
	$park->{lat}	= $parkxml->{View}->{latitude}->{content};
	$park->{lng}	= $parkxml->{View}->{longitude}->{content};
	my $nameaddr = $parkxml->{description};
	$park->{TeamURL}	= $nameaddr->{p}->{b}->{a}->{href};
	$park->{TeamName}	= $nameaddr->{p}->{b}->{a}->{content};
	my $addr	= join '', (@{$nameaddr->{content} || []});
	$addr =~ s/^\s+//mg; $addr =~ s/[\r\n]+/ \/ /g;
	$park->{TeamAddr}	= $addr;

	my $id = $park->{name};
	$id =~ tr/A-Z/a-z/; $id =~ tr/a-z//cd;
	$id = substr($id, 0,5);
	$park->{id} = $id;
	$parks{$id} = $park;
    }
    return \%parks;
}

#USAF	 WBAN  STATION NAME		     CTRY  ST CALL  LAT	   LON	   ELEV(.1M)
#010010 99999 JAN MAYEN			    NO JN    ENJA  +70933 -008667 +00090
#123456 12345 12345678901234567890123456789 12 12345 1234  123123 1234123 123456
#A6x	A5x   A29x			    A2xA2xA2xA4xx  A6x	  A7x	  A6
sub getWeatherStations_ISH($) {
    my $wstns = shift;
    my $filename = "StationList-ISH-Stations.txt";
    open WSTNSFLAT, "<$filename" or die "Can't open $filename: $!";

    # Flat file format
    my $fmt    = "A6x	 A5x   A29x			     A2xA2xA2xA4xx  A6x	 A7x   A6";
    my @fields = qw{id_USAF id_WBAN name region country state callsign lat lng elev};

    # Eat up header stuff
    for my $i (0..10) {
	my $junk = <WSTNSFLAT>;
    }
    my $header = <WSTNSFLAT>;

    # Pull in each line
    for my $line (<WSTNSFLAT>) {
	next if length($line) < 79; chomp $line;
	# Unpack flat record
	my @flat = unpack($fmt, $line);
	next if ($flat[0] eq '999999');
	my $wstn = $wstns->{$flat[1]} || {}; my %wstn = %{$wstn};
	@wstn{@fields} = @flat;

	# Convert numeric fields
	$wstn{lat}  = ($wstn{lat}  ? $wstn{lat}/1000 : -99999 );
	$wstn{lng}  = ($wstn{lng}  ? $wstn{lng}/1000 : -99999 );
	$wstn{elev} = ($wstn{elev} ? $wstn{elev}*10  : -99999 );
	$wstn{year} = {};
	# save it
	$wstns->{$wstn{id_WBAN}} = \%wstn;
    }
    return $wstns;
}

#	   33601 40948 OAKB	       AFGHANISTAN						    KABUL INTL			   KABUL INTL			  19570701 99991231  34 43 00  069 13 00   5876	  5876	6	      SYNOPTIC						  5876	
#914320	   21603 91275 JON  JON	       U. S. MINOR ISLANDS  UM JOHNSTON ISLAND		      +9    JOHNSTON			   JOHNSTON			  19560101 19581001  16 44 00 -169 31 00      7	     9	2	      COOP						     7
#914690 02 61705       NSTU NSTU       AMERICAN SAMOA	    AS WESTERN (DISTRICT)		    PAGO PAGO WSO AP		   PAGO PAGO WSO AP		  19820101 19950101 -14 20 00 -170 43 00     10	    10	6	      COOP						    10
#190770 03 14739 72509 BOS  BOS	  KBOS UNITED STATES	    MA SUFFOLK			      +5    BOSTON WSFO AP		   BOSTON LOGAN INTL AP		  19960401 99991231  42 21 38 -071 00 38     20	    15	2	      ASOS-NWS B ASOS COOP				    20
#0	  1	    2	      3		4	  5	    6	      7		8	  9	   10	      1		2	  3	    4	      5		6	  7	    8	      9	       20	  1	    2	      3		4	  5	    6	      7		8 
#123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345
#A6x	A2xA5x	 A5x   A4x  A5x	  A4x  A20x		    A2xA30x			      A5x   A30x			   A30x				  A8x	   A8x	    AA2xA2xA2xAA3x A2xA2xA6x	A6x    A2xA11x	      A52x						   A3
#123456 12 12345 12345 1234 12345 1234 12345678901234567890 12 123456789012345678901234567890 12345 123456789012345678901234567890 123456789012345678901234567890 12345678 12345678 +DD MM SS +DDD MM SS 123456 123456 12 12345678901 1234567890123456789012345678901234567890123456789012 123
sub getWeatherStations_WBAN($) {
    my $wstns = shift;
    # This one is comprehensive
    my $filename = "StationList-WBAN.txt";
    open WSTNSFLAT, "<$filename" or die "Can't open $filename: $!";

    # Flat file format
    my $fmt    = "A6x	 A2xA5x	  A5x	A4x  A5x   A4x	A20x		     A2xA30x			       A5x   A30x			    A30x			    A8x	     A8x      AA2xA2xA2xAA3x A2xA2xA6x	  A6x	 A2xA11x	A52x						     A3";
    my @fields = qw{id_COOP id_cd id_WBAN id_WMO id_FAA id_NWS id_ICAO 
			country state uscounty tz name_coop name 
			beg end 
			latsgn latdeg latmin latsec lngsgn lngdeg lngmin lngsec 
			elevgd elev elevtype reloc stntype junk};

    # Pull in each line
    for my $line (<WSTNSFLAT>) {
	next if length($line) < 285; chomp $line;
	my %wstn = ();
	# Unpack flat record
	my @a = unpack($fmt, $line);
	@wstn{@fields} = @a;
	#print join',',@a; print "\n"; next;
	# Convert numeric fields
	$wstn{lat}  = ($wstn{latdeg} + $wstn{latmin}/60 + $wstn{latsec}/3600)* ($wstn{latsgn} eq "-" ? -1 : 1);
	$wstn{lng}  = ($wstn{lngdeg} + $wstn{lngmin}/60 + $wstn{lngsec}/3600)* ($wstn{lngsgn} eq "-" ? -1 : 1);
	$wstn{elev} = $wstn{elev} * (2.54 * 12 / 100);
	$wstn{year} = {};
	# save it
	$wstns->{$wstn{id_WBAN}} = \%wstn;
    }
    return $wstns;
}


#WMO	WBAN  YEAR  JAN	   FEB	  MAR	 APR	MAY    JUN    JUL    AUG    ...
#010000 99999 2001  0	   0	  0	 0	0      0      0	     0	    ...
#123456 12345 1234  123456 123456 123456 123456 123456 123456 123456 123456
#A6x	A5x   A4x  "A6x	   "x12
sub getWeatherStationHists_Hourly($) {
    my $wstns = shift;
    my $filename = "StationList-ISH-History.txt";
    open WSTNSFLAT, "<$filename" or die "Can't open $filename: $!";

    # Flat file format
    my $fmt    = "A6x	 A5x   A4x " . "A6x    "x12;
    my @fields = qw{id_WMO id_WBAN year m01 m02 m03 m04 m05 m06 m07 m08 m09 m10 m11 m12};

    # Eat up header stuff
    for my $i (0..5) { my $junk = <WSTNSFLAT> }
    my $header = <WSTNSFLAT>;
    #print $header;

    # Pull in each line
    for my $line (<WSTNSFLAT>) {
	next if length($line) < 79; chomp $line;
	# Unpack flat record
	my ($id_WMO, $id_WBAN, $year, @months) = unpack($fmt, $line);
	my $id = $id_WBAN;
	$wstns->{$id}->{year}->{$year} = (reduce { $a + $b } @months);
    }

    my $years_early = (1900..1973);
    my $years_late  = (1973..2007);
    for my $id (keys %$wstns) {
	my $years = scalar grep { $_ > 3000 } values %{$wstns->{$id}->{year}};
	$wstns->{$id}->{score} = $years;
    }

    return $wstns;
}

sub findNearbyStations_Hourly($$) {
    my $parks = shift;
    my $wstns = shift;

    # FIXME -- this fails near the 0th meridian
    my @parkids = sort keys %$parks;
    my @wstnids = grep { $wstns->{$_}->{state} } (sort keys %$wstns);

    my %parkdists = ();
    for my $parkid (@parkids) {
	my $park    = $parks->{$parkid};
	my $parklat = $park->{lat};
	my $parklng = $park->{lng};
	my @dists = ();
	for my $wstnid (@wstnids) {
	    my $distsq = 
		($parklat - $wstns->{$wstnid}->{lat})**2 + 
		($parklng - $wstns->{$wstnid}->{lng})**2;
	    push @dists, [$distsq, $wstnid, $wstns->{$wstnid}];
	}	
	my @goodwstns;
	# Pull out top 10 stations
	@goodwstns = (sort { $a->[0] <=> $b->[0] } @dists)[0..10];
	# -- Pull out stations within sqrt(0.1) degrees away
	# -- @goodwstns = grep { $_->[0] < 0.05 } @dists;
	# Then sort those by amount of data that's present
	@goodwstns = sort { - ($a->[2]->{score} <=> $b->[2]->{score}) } @goodwstns;
	# And just keep the top 3 or so.
	@goodwstns = @goodwstns[0..5];
	# Storing only the IDs
	$parks->{$parkid}->{wstns} = [ map { $_->[1] } (@goodwstns) ];
    }
}


sub printNearbyStationsGrid($$) {
    # park-stn-years grid
    my $parks = shift;
    my $wstns = shift;

    my @years = (1957..2007);
    printf "%6s-%4s (sc) %s\n", 'parkid', 'wstn', (join ' ', map { substr($_,2,2) } @years);
    for my $park (values %$parks) { 
	for my $wstnid (@{$park->{wstns}}) {
	    my %wstn_yrs = %{$wstns->{$wstnid}->{year}};
	    # print ((join ',',keys %wstn_yrs)."\n");
	    printf "%6s-%4s (%2d)", $park->{id}, 
		$wstns->{$wstnid}->{callsign}, 
		$wstns->{$wstnid}->{score};
	    for my $year (@years) {
		printf "%3d", ($wstn_yrs{$year}||0)/100;
	    }
	    print "\n";
	}
    }
}

sub MakeDataReqPage($$) {
    my $parks = shift;
    my $wstns = shift;

    my $h_baseurl = 'http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?p_cforceoutside=';
    my $h_url_head = '&datasetid=11&lowstat=&highstat=&queryby=COUNTRY&querybykey=243&subqueryby=STATION';
    my $h_stns_beg = '&subqueryitems=';
    my $h_stns_mid = '%2C';
    my $h_elms_req = '&dataelemids=CIG+GF1+DEW+AZ1+AY1+AA1+AW1+MW1+MA1+SLP+AJ1+TMP+KA1+VIS+WND+OC1+OA1+IA1+AC1+MV1+MD1+ED1+AL1+GJ1+';
    my $h_date_beg = '&datequerytype=RANGE';
    my $h_dmin_fmt = '&minyear=%04d&minmonth=01&minday=01&minhour=00';
    my $h_dmax_fmt = '&maxyear=%04d&maxmonth=12&maxday=31&maxhour=23';
    my $h_url_tail = '&listyear=2007&listmonth=10&listday=16&listhour=23&outform=DELSTN&delstring=%2C&outmed=FTP';

    my $d_baseurl  = 'http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?statcount=1';
    my $d_wstn_fmt = '&statid1=%06d&statid2=%06d';
    my $d_date_req = '&datequerytype=RANGE&begyear=1907&begmonth=01&endyear=2007&endmonth=08';
    my $d_url_tail = '&statename=no&dataset=DAILY&srchmthd=RANGE&mprocess=batch&p_cforceoutside=&inelement=ALL&code=ASCII&outform=DELSTN&delstring=%2CF&outmed=FTP&outdest=FILE';

    my $filename = "ParkWeatherGetterDirectory.html";
    open HTMLFILE, ">$filename" or die "Can't open $filename: $!";

    print HTMLFILE "<html>\n<head></head>\n<body style='font-size:10px;'>\n";
    print HTMLFILE "<table>\n";
    print HTMLFILE "<tr>\n";
    print HTMLFILE "  <th>Park</td><td>lat</td><td>lng</td>\n";
    print HTMLFILE "  <td>Weather Station</td><td>lat</td><td>lng</td><td>dist</td>\n";
    print HTMLFILE "  <td>WMO</td><td>USAF</td><td>COOP</td><td>WBAN</td>\n";
    print HTMLFILE "  <td>Y</td><td>Y</td><td>Y</td><td>Y</td><td>Y</td><td>Y</td>\n";
    print HTMLFILE "</tr>\n";
    my ($beg, $end);
    for my $park (values %$parks) { 
	 for my $wstnid (@{$park->{wstns}}) {
	     my $wstn = $wstns->{$wstnid};
	     printf HTMLFILE "<tr>\n";
	     printf HTMLFILE "	<td>%s</td><td>%5.2f</td><td>%5.2f</td>\n", $park->{name}, $park->{lat}, $park->{lng};
	     printf HTMLFILE "	<td>%s</td><td>%5.2f</td><td>%5.2f</td>", substr($wstn->{name},0,25), $wstn->{lat}, $wstn->{lng};
	     printf HTMLFILE "	<td>%6.4f</td>\n", sqrt( ($park->{lat} - $wstn->{lat})**2 + ($park->{lng} - $wstn->{lng})**2 );
	     printf HTMLFILE "	<td>%s</td><td>%s</td><td>%s</td><td>%s</td>", $wstn->{id_WMO}||0, $wstn->{id_USAF}||0, $wstn->{id_COOP}||0, $wstn->{id_WBAN};

	     # Daily Data links
	     if ($wstn->{id_COOP}) {
		 my $d_url = $d_baseurl . sprintf($d_wstn_fmt, $wstn->{id_COOP}, $wstn->{id_COOP}) . $d_date_req . $d_url_tail;
		 printf HTMLFILE "  <td><a href=\"%s\">Daily</a></td>", $d_url;
	     } else {
		 printf HTMLFILE "  <td>--</td>";
	     }	     

	     # Hourly Data Links
	     # 54-64,65-72,73-82,82-92,92-99,00-07
	     my $h_url_most = "$h_baseurl$h_url_head" . $h_stns_beg.($wstn->{id_USAF}||0).$wstnid.$h_stns_mid . "$h_elms_req$h_date_beg";
	     for my $daterange ([1955,1964], [1965,1972], [1973,1982], [1983,1992], [1993,1999], [2000,2007]) {
		 ($beg, $end) = @$daterange;
		 my @years = ($beg..$end);
		 my $inrange = reduce { $a + $b } map { $wstn->{year}->{$_}||0 } @years;
		 my $h_url = $h_url_most . 
		     sprintf($h_dmin_fmt, $beg) . 
		     sprintf($h_dmax_fmt, $end) .
		     $h_url_tail ;
		 printf HTMLFILE "  <td><a href=\"%s\">%s-%s</a> (%3d)</td>", $h_url, substr($beg,2,2), substr($end,2,2), $inrange/1000;
	     }
	     printf HTMLFILE "</tr>\n";
	 }
     }
    print HTMLFILE "</table></body></html>\n";
}

sub dumpParkWeatherXML($$) {
    my %parks = %{$_[0]};
    my %wstns = %{$_[1]};

    # all wstns near some park
    my %wstns_seen = ();
    for my $park (values %parks) { map { $wstns_seen{$_}++ } @{$park->{wstns}} }
    # print join "\n", sort keys %wstns_seen;

    my $fh = new IO::File ">ParkWeatherSetup.xml";
    my $xml = XMLout({Parks	      => [@parks{keys %parks}],
		      WeatherStations => [@wstns{keys %wstns_seen}]},
		     RootName=>'WeatherSetup', 
		     GroupTags => { Parks => 'park', WeatherStations => 'wstn' },
		     OutputFile => $fh
		     );
}


my $parks = getParkLocations();
my $wstns = {};
getWeatherStations_WBAN		($wstns);
getWeatherStations_ISH		($wstns);
getWeatherStationHists_Hourly	($wstns);

findNearbyStations_Hourly	($parks, $wstns);
# printNearbyStationsGrid	($parks, $wstns);
dumpParkWeatherXML		($parks, $wstns);
MakeDataReqPage			($parks, $wstns);

# http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?p_cforceoutside=&datasetid=11&lowstat=&highstat=&queryby=COUNTRY&querybykey=243&subqueryby=STATION&subqueryitems=7245613996%2C&dataelemids=CIG+GF1+DEW+AZ1+AY1+AA1+AW1+MW1+MA1+SLP+AJ1+TMP+KA1+VIS+WND+OC1+OA1+IA1+AC1+MV1+MD1+ED1+AL1+GJ1+&datequerytype=RANGE&minyear=1965&minmonth=01&minday=01&minhour=00&maxyear=1972&maxmonth=12&maxday=31&maxhour=23&listyear=2007&listmonth=10&listday=16&listhour=23&outform=DELSTN&delstring=%2C&outmed=FTP
# http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?p_cforceoutside=&datasetid=11&lowstat=&highstat=&queryby=COUNTRY&querybykey=243&subqueryby=STATION&subqueryitems=72240003937%2C&dataelemids=CIG+GF1+DEW+AZ1+AY1+AA1+AW1+MW1+MA1+SLP+AJ1+TMP+KA1+VIS+WND+OC1+OA1+IA1+AC1+MV1+MD1+ED1+AL1+GJ1+&datequerytype=RANGE&minyear=1955&minmonth=01&minday=01&minhour=00&maxyear=1964&maxmonth=12&maxday=31&maxhour=23&listyear=2007&listmonth=10&listday=16&listhour=23&outform=DELSTN&delstring=%2C&outmed=FTP
# http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?p_cforceoutside=&datasetid=11&lowstat=&highstat=&queryby=COUNTRY&querybykey=243&subqueryby=STATION&subqueryitems=72509014739%2C72530094846%2C72537094847%2C72640014839%2C&dataelemids=CIG+GF1+DEW+AZ1+AY1+AA1+AW1+MW1+MA1+SLP+AJ1+TMP+KA1+VIS+WND+OC1+OA1+IA1+AC1+MV1+MD1+ED1+AL1+GJ1+&datequerytype=RANGE&minyear=2000&minmonth=01&minday=01&minhour=00&maxyear=2005&maxmonth=12&maxday=31&maxhour=23&listyear=2007&listmonth=10&listday=16&listhour=23&outform=DELSTN&delstring=%2C&outmed=FTP
# BAD  http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?statcount=1&statename=CA&dataset=DAILY&srchmthd=STATE&statid1=&statid2=&mprocess=batch&p_cforceoutside=&inelement=ALL&datequerytype=RANGE&begyear=1949&begmonth=01&endyear=2007&endmonth=08&code=ASCII&outform=DELSTN&delstring=%2CF&outmed=FTP&divis=+no&cnty=+no&statid=+04508523129+&clistvalstatus=OK&outdest=FILE
# GOOD http://cdo.ncdc.noaa.gov/cgi-bin/cdo/cdoprod.pl?statcount=1&statid1=085663&statid2=085663&datequerytype=RANGE&begyear=1907&begmonth=01&endyear=2007&endmonth=08&statename=no&dataset=DAILY&srchmthd=RANGE&mprocess=batch&p_cforceoutside=&inelement=ALL&code=ASCII&outform=DELSTN&delstring=%2CF&outmed=FTP&outdest=FILE

