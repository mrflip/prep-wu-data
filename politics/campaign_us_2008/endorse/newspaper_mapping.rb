# -*- coding: utf-8 -*-
NEWSPAPER_MAPPING = {
  # "Boston Herald"                       => ["Boston",                   42.37,   -71.03,],
  # "The Boston Globe"                    => ["Boston",                   42.37,   -71.03,],
  # "Amarillo Globe-News"                 => ['Amarillo',         %q{35° 13' 19" N}, %q{101° 49' 51" W}],
  # "Asheville Citizen-Times"             => ['Asheville',        %q{35° 36' 3" N}, %q{82° 33' 15" W}],
  # "The Baltimore Examiner"              => ['Baltimore',        %q{39° 50' 43" N}, %q{76° 36' 45" W}],
  # "The Repository"                      => ['Canton',           %q{42° 18' 30" N}, %q{91° 37' 30" W}],
  # "Mountain Valley News"                => ['Cedaredge',        %q{38° 54' 6" N}, %q{107° 55' 33" W}],
  # "The Charleston Gazette"              => ['Charleston',       %q{38° 20' 59" N}, %q{81° 37' 58" W}],
  # "Chattanooga Times"                   => ['Chattanooga',      %q{35.0497 N}, %q{98° 39' 22" W}],
  # "Chicago Tribune"                     => ['Chicago',          %q{41° 50' N},    %q{87° 37' W}],
  # "Cortez Journal"                      => ['Cortez',           %q{37° 20' 56" N}, %q{108° 35' 7" W}],
  # "Dayton Daily News"                   => ['Dayton',           %q{44° 52' 31" N}, %q{88° 47' 39" W}],
  # "Foster's Daily Democrat"             => ['Dover',            %q{45° 19' 53" N}, %q{87° 50' 18" W}],
  # "The Durango Herald"                  => ['Durango',          %q{42° 33' 37" N}, %q{107° 52' 46" W}],
  # "The Express-Times"                   => ['Easton',           %q{41° 15' 10" N}, %q{95° 6' 56" W}],
  # "Falls Church News-Press"             => ['Falls Church',     %q{38° 52' 56" N}, %q{77° 10' 17" W}],
  # "The Courier"                         => ['Findlay',          %q{41° 2' 39" N}, %q{83° 39' 0" W}],
  # "The Argus"                           => ['Fremont',          %q{44° 15' 35" N}, %q{96° 29' 52" W}],
  # "The Fresno Bee"                      => ['Fresno',           %q{36° 44' 52" N}, %q{119° 46' 17" W}],
  # "The Daily Sentinel"                  => ['Grand Junction',   %q{39° 3' 50" N}, %q{108° 33' 0" W}],
  # "Gunnison Country Times"              => ['Gunnison',         %q{38.545838 N}, %q{106° 55' 29" W}],
  # "Daily Review"                        => ['Hayward',          %q{37.669660 N}, %q{93° 14' 38" W}],
  # "Honolulu Star-Bulletin"              => ['Honolulu',         %q{21° 18' 25" N}, %q{157° 51' 30" W}],
  # "Arkansas Times"                      => ['Little Rock',      %q{34° 44' 47" N}, %q{95° 52' 59" W}],
  # "La Opinion"                          => ['Los Angeles',      %q{34° 3' N}, %q{118° 15' W}],
  # "Los Angeles Times"                   => ['Los Angeles',      %q{34° 3' N}, %q{118° 15' W}],
  # "The Sun"                             => ['Lowell',           %q{42° 38' 0" N}, %q{71° 19' 0" W}],
  # "The Lufkin Daily News"               => ['Lufkin',           %q{31° 20' 17" N}, %q{94° 43' 44" W}],
  # "The Capital Times"                   => ['Madison',          %q{45° 0' 35" N}, %q{85° 22' 48" W}],
  # "Wisconsin State Journal"             => ['Madison',          %q{45° 0' 35" N}, %q{85° 22' 48" W}],
  # "Union Leader"                        => ['Manchester',       %q{40° 3' 47" N}, %q{72° 31' 19" W}],
  # "Mail Tribune"                        => ['Medford',          %q{42° 19' 36" N}, %q{122° 52' 28" W}],
  # "The Commercial Appeal"               => ['Memphis',          %q{35° 8' 58" N}, %q{90° 2' 56" W}],
  # "The Modesto Bee"                     => ['Modesto',          %q{39° 28' 42" N}, %q{120° 59' 45" W}],
  # "The Monterey County Herald"          => ['Monterey',         %q{36° 36' 1" N}, %q{121° 53' 37" W}],
  # "The Muskegon Chronicle"              => ['Muskegon',         %q{43° 14' 3" N}, %q{86° 14' 54" W}],
  # "Napa Valley Register"                => ['Napa',             %q{38° 17' 50" N}, %q{122° 17' 4" W}],
  # "The Tennessean"                      => ['Nashville',        %q{42° 36' 10" N}, %q{93° 50' 48" W}],
  # "The Standard-Times"                  => ['New Bedford',      %q{41° 38' 10" N}, %q{70° 56' 5" W}],
  # "New York Post"                       => ['New York City',    %q{40° 47' N}, %q{73° 58' W}],
  # "el Dario La Prensa"                  => ['New York City',    %q{40° 47' N}, %q{73° 58' W}],
  # "Oakland Tribune"                     => ['Oakland',          %q{44° 32' 25" N}, %q{90° 23' 4" W}],
  # "Ouray County Plaindealer"            => ['Ouray',            %q{38° 1' 22" N}, %q{107° 40' 15" W}],
  # "Pittsburgh Post-Gazette"             => ['Pittsburgh',       %q{40° 26' 26" N}, %q{79° 57' 00" W}],
  # "Tri-Valley Herald"                   => ['Pleasanton',       %q{37° 39' 45" N}, %q{121° 52' 25" W}],
  # "The Pueblo Chieftain"                => ['Pueblo',           %q{38° 15' 16" N}, %q{104° 36' 31" W}],
  # "The Blade"                           => ['Toledo',          %q{41° 36' 35" N}, %q{83° 33' 52" W}], # for some reason Google Apps barfs on this
  # "The Sacramento Bee"                  => ['Sacramento',       %q{40° 38' 4" N}, %q{87° 15' 56" W}],
  # "San Bernardino Sun"                  => ['San Bernardino',   %q{34° 7' 17" N}, %q{117° 18' 8" W}],
  # "San Francisco Chronicle"             => ['San Francisco',    %q{37° 46' 30" N}, %q{122° 25' 6" W}],
  # "The San Francisco Examiner"          => ['San Francisco',    %q{37° 46' 30" N}, %q{122° 25' 6" W}],
  # "San Jose Mercury News"               => ['San Jose',           %q{37.30° N}, %q{121.85° W}],
  # "San Mateo County Times"              => ['San Mateo',        %q{37° 33' 47" N}, %q{122° 19' 28" W}],
  # "Santa Cruz Sentinel"                 => ['Santa Cruz',       %q{36.97205 N}, %q{106° 2' 48" W}],
  # "Santa Fe New Mexican"                => ['Santa Fe',         %q{35° 41' 13" N}, %q{105° 56' 14" W}],
  # "Seattle Post-Intelligencer"          => ['Seattle',          %q{47° 36' 23" N}, %q{122° 19' 51" W}],
  # "The Seattle Times"                   => ['Seattle',          %q{47° 36' 23" N}, %q{122° 19' 51" W}],
  # "(Spokane) Spokesman-Review"          => ['Spokane',          %q{47° 39' 32" N}, %q{117° 25' 30" W}],
  # "Springfield News-Sun"                => ['Springfield',      %q{45° 23' 46" N}, %q{90° 32' 55" W}],
  # "St. Louis Post-Dispatch"             => ['St. Louis',        %q{38° 38' 53" N}, %q{90° 12' 44" W}],
  # "The Record"                          => ['Stockton',         %q{41° 35' 29" N}, %q{93° 47' 45" W}],
  # "The Storm Lake Times"                => ['Storm Lake',       %q{42° 38' 28" N}, %q{95° 12' 34" W}],
  # "The Columbian"                       => ['Vancouver',        %q{45° 38' 20" N}, %q{122° 39' 37" W}],
  # "Contra Costa Times"                  => ['Walnut Creek',     %q{37.905724 N}, %q{122° 3' 50" W}],
  # "The Washington DC Examiner"          => ['Washington',       38.95, -77.46],
  # "The Washington Post"                 => ['Washington',       38.95, -77.46],
  # "Wheeling News-Register"              => ['Wheeling',         %q{40° 3' 50" N}, %q{80° 43' 16" W}],

  "The Boston Globe"                       => ["Boston",                   42.37000,   -71.03000,  true,],
  "Boston Herald"                          => ["Boston",                   42.37000,   -71.03000,  true,],
  "Amarillo Globe-News"                    => ["Amarillo",                 35.22194,  -101.83083,  true,],
  "Asheville Citizen-Times"                => ["Asheville",                35.60083,   -82.55417,  true,],
  "The Baltimore Examiner"                 => ["Baltimore",                39.84528,   -76.61250,  true,],
  "The Repository"                         => ["Canton",                   42.30833,   -91.62500,  true,],
  "Mountain Valley News"                   => ["Cedaredge",                38.90167,  -107.92583,  true,],
  "The Charleston Gazette"                 => ["Charleston",               38.34972,   -81.63278,  true,],
  "Chattanooga Times"                      => ["Chattanooga",              35.04970,   -98.65611,  true,],
  "Chicago Tribune"                        => ["Chicago",                  41.83333,   -87.61667,  true,],
  "Cortez Journal"                         => ["Cortez",                   37.34889,  -108.58528,  true,],
  "Dayton Daily News"                      => ["Dayton",                   44.87528,   -88.79417,  true,],
  "Foster's Daily Democrat"                => ["Dover",                    45.33139,   -87.83833,  true,],
  "The Durango Herald"                     => ["Durango",                  42.56028,  -107.87944,  true,],
  "The Express-Times"                      => ["Easton",                   41.25278,   -95.11556,  true,],
  "Falls Church News-Press"                => ["Falls Church",             38.88222,   -77.17139,  true,],
  "The Courier"                            => ["Findlay",                  41.04417,   -83.65000,  true,],
  "The Argus"                              => ["Fremont",                  44.25972,   -96.49778,  true,],
  "The Fresno Bee"                         => ["Fresno",                   36.74778,  -119.77139,  true,],
  "The Daily Sentinel"                     => ["Grand Junction",           39.06389,  -108.55000,  true,],
  "Gunnison Country Times"                 => ["Gunnison",                 38.54584,  -106.92472,  true,],
  "Daily Review"                           => ["Hayward",                  37.66966,   -93.24389,  true,],
  "Honolulu Star-Bulletin"                 => ["Honolulu",                 21.30694,  -157.85833,  true,],
  "Arkansas Times"                         => ["Little Rock",              34.74639,   -95.88306,  true,],
  "Los Angeles Times"                      => ["Los Angeles",              34.05000,  -118.25000,  true,],
  "La Opinion"                             => ["Los Angeles",              34.05000,  -118.25000,  true,],
  "The Sun"                                => ["Lowell",                   42.63333,   -71.31667,  true,],
  "The Lufkin Daily News"                  => ["Lufkin",                   31.33806,   -94.72889,  true,],
  "The Capital Times"                      => ["Madison",                  45.00972,   -85.38000,  true,],
  "Wisconsin State Journal"                => ["Madison",                  45.00972,   -85.38000,  true,],
  "Union Leader"                           => ["Manchester",               40.06306,   -72.52194,  true,],
  "Mail Tribune"                           => ["Medford",                  42.32667,  -122.87444,  true,],
  "The Commercial Appeal"                  => ["Memphis",                  35.14944,   -90.04889,  true,],
  "The Modesto Bee"                        => ["Modesto",                  39.47833,  -120.99583,  true,],
  "The Monterey County Herald"             => ["Monterey",                 36.60028,  -121.89361,  true,],
  "The Muskegon Chronicle"                 => ["Muskegon",                 43.23417,   -86.24833,  true,],
  "Napa Valley Register"                   => ["Napa",                     38.29722,  -122.28444,  true,],
  "The Tennessean"                         => ["Nashville",                42.60278,   -93.84667,  true,],
  "The Standard-Times"                     => ["New Bedford",              41.63611,   -70.93472,  true,],
  "New York Post"                          => ["New York City",            40.78333,   -73.96667,  true,],
  "el Dario La Prensa"                     => ["New York City",            40.78333,   -73.96667,  true,],
  "Oakland Tribune"                        => ["Oakland",                  44.54028,   -90.38444,  true,],
  "Ouray County Plaindealer"               => ["Ouray County",             38.02278,  -107.67083,  true,],
  "Pittsburgh Post-Gazette"                => ["Pittsburgh",               40.44056,   -79.95000,  true,],
  "Tri-Valley Herald"                      => ["Pleasanton",               37.66250,  -121.87361,  true,],
  "The Pueblo Chieftain"                   => ["Pueblo",                   38.25444,  -104.60861,  true,],
  "The Blade"                              => ["Toledo",                   41.60972,   -83.56444,  true,],
  "The Sacramento Bee"                     => ["Sacramento",               40.63444,   -87.26556,  true,],
  "San Bernardino Sun"                     => ["San Bernardino",           34.12139,  -117.30222,  true,],
  "The San Francisco Examiner"             => ["San Francisco",            37.77500,  -122.41833,  true,],
  "San Francisco Chronicle"                => ["San Francisco",            37.77500,  -122.41833,  true,],
  "San Jose Mercury News"                  => ["San Jose",                 37.30000,  -121.85000,  true,],
  "San Mateo County Times"                 => ["San Mateo",                37.56306,  -122.32444,  true,],
  "Santa Cruz Sentinel"                    => ["Santa Cruz",               36.97205,  -106.04667,  true,],
  "Santa Fe New Mexican"                   => ["Santa Fe",                 35.68694,  -105.93722,  true,],
  "The Seattle Times"                      => ["Seattle",                  47.60639,  -122.33083,  true,],
  "Seattle Post-Intelligencer"             => ["Seattle",                  47.60639,  -122.33083,  true,],
  "(Spokane) Spokesman-Review"             => ["Spokane",                  47.65889,  -117.42500,  true,],
  "Springfield News-Sun"                   => ["Springfield",              45.39611,   -90.54861,  true,],
  "St. Louis Post-Dispatch"                => ["St. Louis",                38.64806,   -90.21222,  true,],
  "The Record"                             => ["Stockton",                 41.59139,   -93.79583,  true,],
  "The Storm Lake Times"                   => ["Storm Lake",               42.64111,   -95.20944,  true,],
  "The Columbian"                          => ["Vancouver",                45.63889,  -122.66028,  true,],
  "Contra Costa Times"                     => ["Walnut Creek",             37.90572,  -122.06389,  true,],
  "The Washington DC Examiner"             => ["Washington",               38.95000,   -77.46000,  true,],
  "The Washington Post"                    => ["Washington",               38.95000,   -77.46000,  true,],
  "Wheeling News-Register"                 => ["Wheeling",                 40.06389,   -80.72111,  true,],

  "The Denver Post"                        => ["Denver",                   39.75000,  -104.87000,  true,], # CO
  "Miami Herald"                           => ["Miami",                    25.82000,   -80.28000,  true,], # FL
  "Atlanta Journal-Constitution"           => ["Atlanta",                  33.65000,   -84.42000,  true,], # GA
  "Chicago Sun-Times"                      => ["Chicago",                  41.90000,   -87.65000,  true,], # IL
  "Bangor Daily News"                      => ["Bangor",                   44.80000,   -68.82000,  true,], # ME
  "Detroit Free Press"                     => ["Detroit",                  42.42000,   -83.02000,  true,], # MI
  "Kansas City Star"                       => ["Kansas City",              39.32000,   -94.72000,  true,], # MO
  "The Daily News"                         => ["New York City",            40.77000,   -73.98000,  true,], # NY
  "el Diario La Prensa"                    => ["New York City",            40.77000,   -73.98000,  true,], # NY
  "Philadelphia Inquirer"                  => ["Philadelphia",             39.88000,   -75.25000,  true,], # PA
  "The Salt Lake Tribune"                  => ["Salt Lake City",           40.78000,  -111.97000,  true,], # UT
  "Tampa Tribune"                          => ["Tampa",                    27.97000,   -82.53000,  true,], # FL
  "Dallas Morning News"                    => ["Dallas",                   32.85000,   -96.85000,  true,], # TX
  "The Plain Dealer"                       => ["Cleveland",                41.52000,   -81.68000,  true,], # OH
  "The Oregonian of Portland"              => ["Portland",                 45.60000,  -122.60000,  true,], # OR

  "Naples Daily-News"                      => ["Naples",                   26.13000,   -81.80000,  true,], # FL
  "Southwest News-Herald"                  => ["Chicago",                  41.90000,   -87.65000,  true,], # IL
  "Brunswick Times-Record"                 => ["Brunswick",                43.88000,   -69.93000,  true,], # ME
  "Las Cruces Sun-News"                    => ["Las Cruces",               32.30000,  -106.77000,  true,], # NM
  "Wilmington Star-News"                   => ["Wilmington",               34.27000,   -77.92000,  true,], # NC
  "Yamhill Valley News-Register"           => ["Portland",                 45.60000,  -122.60000,  true,], # OR
  "Yakima Herald-Republic"                 => ["Yakima",                   46.57000,  -120.53000,  true,], # WA
  "Huntington Herald-Dispatch"             => ["Huntington",               38.37000,   -82.55000,  true,], # WV
}


# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Chicago+Sun-Times+circulation'             | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Detroit+Free+Press+circulation'            | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Atlanta+Journal-Constitution+circulation'  | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Dallas+Morning+News+circulation'           | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Miami+Herald+circulation'                  | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Philadelphia+Inquirer+circulation'         | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=The+Salt+Lake+Tribune+circulation'         | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Tampa+Tribune+circulation'                 | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'

# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Bangor+Daily+News+circulation'             | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Brunswick+Times-Record+circulation'        | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Huntington+Herald-Dispatch+circulation'    | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Las+Cruces+Sun-News+circulation'           | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Naples+Daily-News+circulation'             | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Southwest+News-Herald+circulation'         | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=The+Oregonian+of+Portland+circulation'     | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=The+Plain+Dealer+circulation'              | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Wilmington+Star-News+circulation'          | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Yakima+Herald-Republic+circulation'        | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'
# wget -nv -O- 2>/dev/null 'http://google.com/search?q=Yamhill+Valley+News-Register+circulation'  | ruby -ne '($_ =~ %r{id=aob([^!]+)!}) && puts($1)'

circs = [
  # ["Chicago Sun-Times",                "368,062", "324,074"],
  # ["Detroit Free Press",               "329,989", "640,356"],
  # ["The Atlanta Journal-Constitution", "357,399", "523,687"],
  # ["The Dallas Morning News",          "411,919", "563,079"],
  # ["The Denver Post",                  "255,452", "704,806"],
  # ["The Miami Herald",                 "272,299", "342,432"],
  # ["The Philadelphia Inquirer",        "352,593", "688,670"],
  # ["The Salt Lake Tribune",            "128,186", "149,320"],
  # ["The Tampa Tribune",                "226,990", "226,990"],
  # ["Bangor Daily News",                "28600",   "",     "200000"],  # http://company.bangornews.com/advertising/audience-reach

  # http://www.burrellesluce.com/top100/2008_Top_100List.pdf
  ["USA Today",                                        2284219,          0],
  ["The Wall Street Journal",                          2069463,          0],
  ["The New York Times",                               1077256,    1476400],
  ["Los Angeles Times",                                 773884,     1101981],
  ["The Daily News - New York, NY",                     703137,      704157],
  ["The New York Post",                                 702488,      401315],
  ["Washington Post",                                   673180,      890163],
  ["Chicago Tribune",                                   541663,      898703],
  ["Houston Chronicle",                                 494131,      632797],
  ["Arizona Republic - Phoenix, AZ",                    413332,      515523],
  ["Newsday - Melville, NY",                            379613,      441728],
  ["San Francisco Chronicle",                           370345,      424603],
  ["Dallas Morning News",                               368313,      520215],
  ["The Boston Globe",                                  350605,      525959],
  ["The Star-Ledger - Newark, NJ",                      345130,      500382],
  ["Philadelphia Inquirer",                             334150,      630665],
  ["The Plain Dealer - Cleveland, OH",                  330280,      428090], # Daily: 335,656 Sunday 442,484
  ["The Atlanta Journal-Constitution",                  326907,      497149],
  ["Star-Tribune - Minneapolis, MN",                    322362,      534750],
  ["St. Petersburg Times",                              316007,      432779],
  ["The Chicago Sun-Times",                             312274,      247469],
  ["Detroit Free Press",                                308944,      606374],
  ["The Oregonian - Portland, OR",                      304399,      361988],
  ["The San Diego Union Tribune",                       288669,      355537],
  ["The Sacramento Bee",                                268755,      307480],
  ["The Indianapolis Star",                             255303,      324349],
  ["St. Louis Post-Dispatch",                           255057,      414564],
  ["The Kansas City Star",                              252785,      345332],
  ["The Orange County (CA) Register",                   250724,      311982],
  ["The Miami Herald",                                  240223,      311245],
  ["San Jose Mercury News",                             234772,      251851],
  ["The Sun - Baltimore, MD",                           232360,      372970],
  ["The Orlando Sentinel",                              227593,      332030],
  ["San Antonio Express-News",                          225447,      315959],
  ["The Rocky Mountain News",                           225226,           0],
  ["The Denver Post",                                   225193,           0],
  ["The Seattle Times",                                 220863,           0],
  ["Tampa Tribune",                                     220522,           0],
  ["South Florida Sun-Sentinel - Ft. Lauderdale, FL",   218286,      303399],
  ["Milwaukee Journal Sentinel",                        217755,      384539],
  ["The Courier-Journal - Louisville, KY",              215328,      258778],
  ["Pittsburgh Post-Gazette",                           214374,      331053],
  ["The Cincinnati Enquirer",                           212369,      279825],
  ["The Charlotte Observer",                            210616,      264170],
  ["Fort Worth Star-Telegram",                          207045,      289974],
  ["The Oklahoman - Oklahoma City, OK",                 201771,      262150],
  ["The Columbus Dispatch",                             199524,      334422],
  ["St. Paul Pioneer-Press",                            191768,      252055],
  ["The Detroit News",                                  188171,           0],
  ["Contra Costa (CA) Times",                           183086,      194203],
  ["The Boston Herald",                                 182350,      105629],
  ["Arkansas Democrat-Gazette - Little Rock, AR",       182212,      274494],
  ["New Orleans Times-Picayune",                        179834,      199970],
  ["Omaha World-Herald",                                178545,      219795],
  ["The Buffalo News",                                  178365,      260445],
  ["The News & Observer - Raleigh, NC",                 176083,      211245],
  ["Richmond Times-Dispatch",                           175265,      205895],
  ["The Virginian Pilot",                               175005,      200012],
  ["Las Vegas Review-Journal",                          174341,      199602],
  ["Austin American-Statesman",                         170309,      206505],
  ["The Hartford Courant",                              168158,      237933],
  ["The Palm Beach Post",                               164474,      195608],
  ["The Press-Enterprise - Riverside, CA",              164189,      172730],
  ["The Record - Hackensack, NJ",                       163329,      195525],
  ["Investor’s Business Daily - Los Angeles, CA",       161421,           0],
  ["The Tennessean - Nashville, TN",                    161131,      219044],
  ["Tribune-Review - Greensburg, PA",                   150911,      192423],
  ["The Fresno Bee",                                    150334,      171039],
  ["The Commercial Appeal",                             146961,      188040],
  ["Democrat & Chronicle - Rochester, NY",              145913,      199533],
  ["The Florida Times-Union",                           144391,      201352],
  ["Daily Herald - Arlington Heights, IL",              143152,      141091],
  ["Asbury Park Press - Neptune, NJ",                   140882,      184095],
  ["The Birmingham News",                               140438,      170151],
  ["The Honolulu Advertiser",                           140331,      150276],
  ["The Providence Journal",                            139055,      192849],
  ["The Des Moines Register",                           138519,      222122],
  ["The Los Angeles Daily News - Woodland Hills, CA",   137344,      145164],
  ["Seattle Post-Intelligencer",                        129563,           0],
  ["The Grand Rapids Press",                            128930,      177026],
  ["The Salt Lake Tribune",                             121699,      143296],
  ["The Akron Beacon Journal",                          119929,      155436],
  ["The Blade - Toledo, OH",                            119901,      147141],
  ["The Knoxville News-Sentinel",                       117262,      147939],
  ["Dayton Daily News",                                 116690,      157833],
  ["Sarasota Herald-Tribune",                           114904,      125644],
  ["La Opinion - Los Angeles, CA",                      114892,       56027],
  ["Arizona Daily Star - Tucson",                       113373,      164033],
  ["Tulsa World",                                       112968,      160052],
  ["The News Tribune - Tacoma",                         111778,      125955],
  ["The News Journal - New Castle, DE",                 110171,      125244],
  ["Post-Standard, Syracuse, NY",                       110061,      158529],
  ["Lexington (KY) Herald-Leader",                      109624,      135250],
  ["Morning Call - Allentown, PA",                      108797,      140789],
  ["Journal News - Rockland County",                    108092,      125829],
  ["Philadelphia Daily News",                           107269,           0],
  ["Albuquerque Journal",                               102902,      137623],
  ["The State - Columbia, SC",                          101010,      128564],
  ["The Post and Courier - Charleston, SC",             100400,      110289],
  ["The Daytona Beach News-Journal",                    99627,       116700],
]
# circs.each do |paper, daily, sun, weekly|
#   daily    = daily.gsub(/,/,'').to_i if daily.is_a?(String)
#   sun      = sun.gsub(/,/,'').to_i   if sun.is_a?(String)
#   weekly ||= ( daily * 6 + sun )
#   puts '  [%-50s %10d, %10d, %10d,]' % ["\"#{paper}\",", daily, sun, weekly]
# end


