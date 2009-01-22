#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
$: << File.dirname(__FILE__)+'/../../lib'
require 'hadoop'                       ; include Hadoop
require 'unicode_names'
require 'unicode_planes'
require 'unicode_classification'

def robustly_decode_entity entity_num
  # Decoding
  if is_bad_char?(entity_num)
    entity_alpha  = "&##{entity_num};"
    decoded = ''
  else
    # this silly thing will re-encode using named entities (&yen;, &raquo;, etc.)
    entity_alpha  = "&##{entity_num};".hadoop_decode.hadoop_encode
    decoded = entity_alpha.hadoop_decode
  end
  [entity_alpha, decoded]
end


#
# For all the entities in the scrape,
#
$stderr.puts "Naming each entity from input"
$stdin.each do |line|
  entity_num, freq, *_ = line.chomp.split("\t")
  entity_num = entity_num.to_i
  # Name
  entity_name           = find_entity_name(entity_num, freq)
  # Decode
  entity_alpha, decoded = robustly_decode_entity(entity_num)
  # find classification
  classification_info   = find_entity_classification(entity_num)
  # Find plane
  plane_info            = find_entity_classification(entity_num)
  # Emit
  puts [entity_num, freq, entity_alpha, decoded, entity_name, classification_info, plane_info].flatten.join("\t")
end


