#!/usr/bin/env ruby
LOC_RE_IPHONE = %r{iPhone: (-?\d+\.\d+)\,(-?\d+\.\d+)}
LOC_RE_COORDS = %r{(-?\d+\.\d+)\,\s*(-?\d+\.\d+)}
LOC_RE_ZIP5   = %r{\b(\d{5})\b}
LOC_RE_CITYST = %r{(.*),(.*)}
$stdin.each do |line|
  context, key, *vals = line.chomp.split "\t"
  case context
  when 'twitter_user_partial' then id, screen_name, _, _, _, _,   location, _, _, scraped_at = vals
  when 'twitter_user_profile' then id, screen_name, _, location, _, time_zone, _, scraped_at = vals
  end

  if ! scraped_at then warn "Funny line #{line}" ; next ; end
  scraped_at.gsub! /-/, ''
  location.gsub! /^"|"$/, ''
  source, txt, lat, lng = case
  when location.strip.empty?             then next;
  when m = LOC_RE_IPHONE.match(location) then ['iPhone', "#{$1},#{$2}", $1, $2 ]
  when m = LOC_RE_COORDS.match(location) then ['coords', "#{$1},#{$2}", $1, $2 ]
  when m = LOC_RE_CITYST.match(location) then ['named',  location]
  when m = LOC_RE_ZIP5.match(location)   then ['zip_5',  $1]
  else ['other', location]
  end
  puts ['location', id, screen_name, lat, lng, source, time_zone, txt, scraped_at].join "\t"
end

#
# Also: get time_zone and utc_offset from twitter_user_profiles
#

# SELECT location, COUNT(*) AS num FROM twitter_user_partials t
# WHERE location NOT LIKE 'iPhone%' AND location NOT LIKE '%.%_,%.%'
# GROUP BY location
# ORDER BY num desc
# LIMIT 1000

# cat out/sorted-20081213-all/twitter_user_partial.tsv | ./analysis/geolocate.rb | sort -k1,2 | ./hadoop_uniq_without_timestamp.rb  > fixd/analyzed/geolocations.tsv
# for foo in coords iphone named zip_5 other ; do grep -i "     $foo    " fixd/analyzed/geolocations.tsv | cut -d'      ' -f7 | sort | uniq -c | sort -n > fixd/analyzed/geolocations-$foo.tsv ; done


# function calcDist(lon1,lat1,lon2,lat2) {
#    var r = 3963.0;
#    var multiplier = 1;
#    return multiplier * r * Math.acos(Math.sin(lat1/57.2958) *
#            Math.sin(lat2/57.2958) +  Math.cos(lat1/57.2958) *
#            Math.cos(lat2/57.2958) * Math.cos(lon2/57.2958 -
#            lon1/57.2958));
# }:
