#!/usr/bin/env ruby
$: << File.dirname(__FILE__)

require 'unicode_classification'

Fixnum.class_eval{  def include?(x) x == self end }

File.open(File.dirname(__FILE__)+'/unicode/entity_names.tsv').each do |line|
  entity_num, entity_name = line.chomp.split("\t")
  entity_num = entity_num.to_i
# UNICODE_CLASSIFICATION_MAPPING
  plane_info = UNICODE_CLASSIFICATION_MAPPING.find{|plane, info| plane.include?(entity_num) }
  raise "No definition for entity &##{entity_num}; (#{entity_name})" unless plane_info

  puts [entity_num, entity_name, plane_info].flatten.join("\t")
end

