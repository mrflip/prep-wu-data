#!/usr/bin/env ruby

File.open(File.dirname(__FILE__)+'/unicode/UnicodeData.txt').each do |line|

  entity_hex, name, category,
  combining, bidi, decomp,
  as_decimal, as_digit,
  as_numeric, mirrored, u1_name, comment,
  to_upper, to_lower, to_title            = line.chomp.split(";")

  entity = entity_hex.hex
  name = name.split(/\s+/).map(&:capitalize).join(" ")
  name = name.gsub(/\bCjk\b/i, 'CJK')
  puts [entity, name].join("\t")

end
