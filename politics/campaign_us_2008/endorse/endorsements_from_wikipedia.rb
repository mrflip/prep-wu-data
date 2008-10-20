#!/usr/bin/env ruby
require 'newspaper_mapping'


Newspaper = Struct.new(:name, :prez04, :city, :state)
BY_CITY = { }; BY_NAME = { }

SPLIT_LINK  = '\[\[([^|]+)\|([^|\]]+)\]\]'
SIMPLE_LINK = '\[\[([^|]+)\]\]'
BOLD_TEXT   = "''([^\\']+)''"
def parse_wikipedia_page
  prez04 = ''
  out_file = File.open('fixd/endorsements_from_wikipedia-raw.txt', 'w')
  File.open('rawd/Newspaper_endorsements_in_the_United_States_presidential_election,_2004.txt').each do |line|
    if line =~ /^\* (.*)$/ then prez04 = $1 ; next end
    next unless line =~ /^\*\*/
    line.gsub!(/^\*\*(?:The )?/, ''); line.strip!.chomp!
    city_st, name, partial_name = [nil]*3
    case
    when /^#{SPLIT_LINK} '*#{SPLIT_LINK}'*$/.match(line)   then city_st, name = $1, $3
    when /^#{SPLIT_LINK} #{BOLD_TEXT}$/.match(line)        then city_st, name = $1, $3
    when /^#{SIMPLE_LINK} '*#{SPLIT_LINK}'*$/.match(line)  then city_st, name = $1, $2
    when /^#{SIMPLE_LINK} #{BOLD_TEXT}$/.match(line)       then city_st, partial_name = $1, $2
    when /^#{SIMPLE_LINK}$/.match(line)                    then          name = $1
    else
      puts line
      next
    end
    if (m = /(.*), (.*)/.match(city_st)) then city, state = m.captures else city, state = [city_st, ''] end
    name = "#{city} #{partial_name}" if !name
    name.gsub!(/[\[\]]+/, '')
    np = Newspaper.new(name, prez04, city, state)
    (BY_CITY[city]||=[]) << np
    BY_NAME[np.name] = np
    f << ( "%-60s | %-10s | %-20s | %-20s\n" % np.to_a )
  end
end

def load_parsed
  File.open('endorsements_from_wikipedia.txt').map{|line| line.split(/\s*\|\s*/)}.each do |name, prez04, city, state|
    np = Newspaper.new(name, prez04, city, state)
    (BY_CITY[city]||=[]) << np
    BY_NAME[np.name] = np
  end
end

load_parsed()
NEWSPAPER_CIRCS.sort_by{|name,info| [name, info[7], ] }.each do |name, info|
  rank, circ, daily, sunday, lat, lng, st, city, needfix = info
  # #
  # # Try to match papers by city
  # #
  # if BY_CITY.include?(city)
  #   next if BY_CITY[city].find{|np| np.name == name}
  #   BY_CITY[city].each do |np|
  #     # puts ( "%-20s | %-30s | %-30s" % [city, name, np.name] )
  #   end
  # else
  #   # $stderr.puts("Missing city #{city}") if rank > 0
  # end

  if (np = BY_NAME[name])
    prez04 = case np.prez04 when 'Kerry' then 'K' when 'Bush' then 'B' when '(none)' then 'N/A' end
    puts ( "  %-30s => '%s'," % ["\"#{name}\"", prez04] )
  else
    # $stderr.puts("Missing paper #{name}") if rank > 0
  end

end
