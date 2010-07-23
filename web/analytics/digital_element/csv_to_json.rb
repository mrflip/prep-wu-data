require 'rubygems'
require 'json'

FIELDS     = %w[country region city conn_speed country_conf region_conf city_conf metro_code latitude longitude country_code region_code city_code continent_code two_letter_country]
CONVERTERS = %w[to_s to_s to_s to_s to_i to_i to_i to_i to_f to_f to_i to_i to_i to_i to_s]


$stdin.each do |line|
  raw_values = line.strip.split(';')
  starting_ip = raw_values.shift
  ending_ip   = raw_values.shift
  values     = {}
  raw_values.each_with_index do |value, index|
    field, converter = FIELDS[index], CONVERTERS[index]
    next unless field && converter
    values[field] = value.send(converter)
  end
  $stdout.puts([starting_ip, ending_ip, values.to_json.to_s].join("\t"))
end

  
  
  

