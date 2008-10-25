#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'faster_csv'; require 'xmlsimple'
require 'activesupport'
#

def dump_filename base, ext
  if base.is_a? Class then base = base.to_s.underscore.pluralize end
  out_filename = "fixd/#{base}.#{ext}"
  puts "Dumping #{ext.to_s.upcase} file to #{out_filename}"
  out_filename
end
def magic_klass objs, options={ }
  case
  when options[:klass]          then options[:klass]
  when objs.is_a?(Hash)         then objs.values.first.class
  when objs[0].is_a?(Struct)    then objs[0].class
  end
end
def magic_headers objs, klass, options={ }
  case
  when options[:headers]        then options[:headers]
  when objs.is_a?(Hash)         then [options[:keyname]] + klass.members
  when objs[0].is_a?(Struct)    then klass.members
  else raise("Can't generate headers for #{objs.inspect[0.1000]}")
  end
end
def magic_untangle_objs objs, options={ }
  case
  when options[:raw]            then objs
  when objs.is_a?(Hash) && options[:literalize_keys]
    objs.map{|k,v| [k.inspect]+v.to_a}
  when objs.is_a?(Hash)         then objs.map{|k,v| [k]+v.to_a}
  when objs[0].is_a?(Struct)    then objs
  else raise("Don't recognize #{objs.inspect[0.1000]}")
  end
end

def dump_csv objs, options={}
  options = options.reverse_merge :separator => ',', :keyname => 'key'
  klass, headers, separator = options.values_at(:klass, :headers, :separator)
  klass   = magic_klass         objs,        options
  headers = magic_headers       objs, klass, options
  objs    = magic_untangle_objs objs,        options
  ext     = case separator when ',' then :csv when "\t" then :tsv end
  out_filename = dump_filename(klass, ext)
  #
  # Do it
  #
  FasterCSV.open(out_filename, "w", :col_sep => separator) do |csv|
    csv << headers.map{|header| header.titleize}
    objs.each do |obj|
      csv << obj.to_a
    end
  end
end

def dump_yaml objs, options={}
  klass   = magic_klass objs, options
  YAML.dump(objs, File.open(dump_filename(klass, :yaml), 'w'))
end
def dump_xml objs, options={}
  klass   = magic_klass objs, options
  File.open(dump_filename(klass, :xml), 'w') do |f|
    f << XmlSimple.xml_out(objs, 'KeepRoot' => true)
  end
end
def hash_to_objs hsh, klass
  hsh.map{|vals| klass.new(*vals) }
end

def dump_all objs, type_options
  type_options.each do |type, options|
    options ||= { }
    case type
    when :xml   then dump_xml  objs, options
    when :yaml  then dump_yaml objs, options
    when :csv   then dump_csv  objs, options
    end
  end
end


if $ARGV.include?('--dump-all')
  # require 'metropolitan_areas'
  # dump_all  MetropolitanArea.all_metros, [:yaml, :xml, :csv, ]
  # dump_all  CityMetro.cities_to_metros,  [:yaml, [:csv, { :literalize_keys => true }]]
  # 
  # require 'state_abbreviations'
  # objs = hash_to_objs(STATE_ABBREVIATIONS, StateAbbreviation = Struct.new(:state_name, :abbreviation))
  # dump_all objs, [:yaml, :xml, :csv]
  
  require 'cities_mapping'  
  objs = hash_to_objs(CITIES_MAPPING, CityGeolocation = Struct.new(:city, :state, :airport, :lat, :lng))
  dump_all objs, [:yaml, :xml, :csv]  
end
