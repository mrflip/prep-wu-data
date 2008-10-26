# -*- coding: utf-8 -*-
OLD_NEWSPAPER_MAPPING = {

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
}


def fix_coord coord
  if coord =~ / ([NSEW])/
    sgn = { "N" => 1, "E" => 1, "W" => -1, "S" => -1}[$1]
    m = /([\d\.]+)°(?: ([\d\.]+)\'(?: ([\d\.]+)\")?)? ([NSEW])/.match(coord)
    if m
      deg, min, sec, _ = m.captures
      coord = sgn * (deg.to_f + (min||0).to_f/60 + (sec||0).to_f/3600)
    else
      coord = sgn * coord[0..-3].to_f
    end
  end
  coord
end

def coords_from_google(paper, city, st)
    lat = fix_coord raw_lat
    lng = fix_coord raw_lng
    if get_city_coords(city, st)[0] then lat, lng = get_city_coords(city, st)  end

end
