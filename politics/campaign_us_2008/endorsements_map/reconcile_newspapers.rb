# puts YAML.load(File.open("data/newspapers_burrelles_luce.yaml")).to_yaml


# def fix_city_and_paper(orig_paper, state, circ)
#   # extract embedded city info
#   if orig_paper =~ /^(.*) \((.*)\)(.*)/
#     paper, city = [$1+($3||''), $2]
#   else
#     paper = orig_paper
#   end
#   if (orig_paper =~ /Lowell.*Sun/) ||
#      (orig_paper =~ /Stockton.*Record/) ||
#      (orig_paper =~ /Daily News.*Los Angeles/)
#     paper = orig_paper
#   end
#   # and un-abbreviate state
#   st = STATE_ABBREVIATIONS[state.upcase]
#   case
#   when NEWSPAPER_CIRCS.include?(paper)
#     rank, circ2, daily, sun, lat, lng, st, city, needsfix = NEWSPAPER_CIRCS[paper]
#     if circ == 0 then circ = daily end
#     if needsfix
#       lat, lng = get_city_coords(city, st)
#       find_missing_cities(city, st) if !lat
#       lat ||= 0; lng ||= 0
#       dump_for_newspaper_mapping(rank, circ, daily, sun, lat, lng, st, city, paper, true, 'fixed loc')
#     elsif circ2 != circ
#       dump_for_newspaper_mapping(rank, circ, daily, sun, lat, lng, st, city, paper, false, 'fixed circ')
#     end
#   else
#     rank, daily, sun = [0,0,0]
#     city  ||= orig_paper.gsub(/^The /, '').gsub(/([^ ]*) ([^ ]*).*?/, '\1 \2')
#     lat, lng = get_city_coords(city, st)
#     lat ||= 0; lng ||= 0
#     dump_for_newspaper_mapping(rank, circ, daily, sun, lat, lng, st, city, paper, true, 'needs city fixed')
#   end
#   if paper == 'USA Today' then city = "[National]"; st = '' ; lng, lat = ll_from_xy(1050, 2000 + 758-75) end # fix position in newspar_mmpao
#   [rank, circ, daily, sun, lat, lng, st, city, paper]
# end
# def dump_for_newspaper_mapping rank, circ, daily, sun, lat, lng, st, city, paper, needsfix, comment
#     puts '  %-40s => [%3d, %9d, %9d, %9d, %-9s %-9s "%s", %-30s %s], # %s' % [
#       "\"#{paper}\"", rank, circ, daily, sun,
#       "#{'%8.3f'%(lat)},", "#{'%8.3f'%(lng)},",  st, "\"#{city}\",", needsfix, comment]
# end
# # Find missing cities
# def find_missing_cities city, st
#   puts('%s%-20s%s' %
#     [ %Q{wget -O- \"http://www.census.gov/cgi-bin/gazetteer?},
#       '%s,+%s" ' % [city.gsub(/\s/,"+"), st],
#       %q{ -nv 2>/dev/null | egrep -i '(<li><strong|Location)'},
#     ]) if (!get_city_coords(city, st)[1])
# end
# def find_prez04_from_wikipedia endorsement
#   wp_prez04 = PREZ04_FROM_WIKIPEDIA[endorsement.paper]
#   return unless wp_prez04
#   if (wp_prez04 != endorsement.prez_04)
#     if endorsement.prez_04 == ''
#       endorsement.prez04 = PREZ04[wp_prez04]
#     else
#       puts "Mismatch: wp #{wp_prez04} e&p #{endorsement.prez04} for #{endorsement.paper}"
#     end
#   end
# end
