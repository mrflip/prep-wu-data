#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'yaml'; require 'json'; require 'faster_csv'; require 'xmlsimple'
require 'activesupport'
require 'imw/utils/extensions/core'
#

module StructDumper
  def self.dump_all objs, type_options
    type_options.each do |type, options|
      dump_from objs, type, options
    end
  end
  def self.dump_from objs, type, options
    case type
    when :xml   then dump_xml  objs, options
    when :yaml  then dump_yaml objs, options
    when :csv   then dump_csv  objs, options
    when :tsv   then dump_tsv  objs, options
    end
  end
  def self.load_all klass, type_options
    type_options.map do |type, options|
      load_from klass, type, options||{}
    end
  end
  def self.load_from klass, type, options = {}
    case type
    when :xml   then load_xml  klass, options
    when :yaml  then load_yaml klass, options
    when :csv   then load_csv  klass, options
    when :tsv   then load_tsv  klass, options
    end
  end

  #
  # Automaticall generate destination filename
  #
  def self.dump_filename base, ext, options={}
    if base.is_a? Class then base = base.to_s.underscore.pluralize end
    dir = options[:dir] || :fixd
    out_filename = "#{dir}/#{base}.#{ext}"
    puts "#{ext.to_s.upcase} file: #{out_filename}"
    out_filename
  end
  #
  def self.hash_to_objs hsh, klass
    hsh.map{|vals| klass.new(*vals) }
  end
  #
  def self.magic_klass objs, options={ }
    case
    when options[:klass]          then options[:klass]
    when objs.is_a?(Hash)         then objs.values.first.class
    when objs[0].is_a?(Struct)    then objs[0].class
    end
  end
  def self.magic_headers objs, klass, options={ }
    case
    when options[:headers]        then options[:headers]
    when objs.is_a?(Hash)         then [options[:keyname]||'key'] + klass.members
    when objs[0].is_a?(Struct)    then klass.members
    else raise("Can't generate headers for #{objs.inspect[0.1000]}")
    end
  end
  def self.magic_untangle_objs objs, options={ }
    case
    when options[:raw]            then objs
    when objs.is_a?(Hash) && options[:literalize_keys]
      objs.map{|k,v| [k.to_json]+v.to_a}
    when objs.is_a?(Hash)         then objs.map{|k,v| [k]+v.to_a}
    when objs[0].is_a?(Struct)    then objs
    else raise("Don't recognize #{objs.inspect[0.1000]}")
    end
  end

  def self.dump_csv objs, options={}
    options = options.reverse_merge :separator => ','
    klass, headers, separator = options.values_at(:klass, :headers, :separator)
    klass   = magic_klass         objs,        options
    headers = magic_headers       objs, klass, options
    objs    = magic_untangle_objs objs,        options
    ext     = case separator when ',' then :csv when "\t" then :tsv end
    out_filename = dump_filename(klass, ext, options)
    #
    # Do it
    #
    FasterCSV.open(out_filename, "w", :col_sep => separator) do |csv|
      csv << headers.map{|header| header}
      objs.each do |obj|
        csv << obj.to_a
      end
    end
  end
  def self.load_csv klass, options={}
    options     = options.reverse_merge :separator => ',', :keyname => 'key'
    separator,_ = options.values_at(:separator)
    ext         = case separator when ',' then :csv when "\t" then :tsv else warn "Bad separator: #{options.inspect}" end
    in_filename = dump_filename(klass, ext, options)
    #
    # Do it
    #
    objs = {}
    FasterCSV.open(in_filename, :col_sep => separator) do |csv|
      headers = csv.shift; k_headers = magic_headers({}, klass, options)
      warn "key mismatch: #{headers.to_json}\n#{k_headers.to_json}" unless headers == k_headers
      csv.each do |row|
        key = row.shift
        key = JSON.load(key) if options[:literalize_keys]
        objs[key] = klass.new(*row)
      end
    end
    objs
  end
  #
  # TSV
  #
  def self.dump_tsv(objs, options={})   dump_csv objs,  options.merge({:separator => "\t"})  end
  def self.load_tsv(klass, options={})  load_csv klass, options.merge({:separator => "\t"}) end
  #
  # YAML
  #
  def self.dump_yaml objs, options={}
    klass   = magic_klass objs, options
    YAML.dump(objs, File.open(dump_filename(klass, :yaml, options), 'w'))
  end
  def self.load_yaml klass, options={}
    objs = YAML.load(File.open(dump_filename(klass, :yaml, options)))
  end
  #
  # XML
  #
  def self.dump_xml objs, options={}
    klass   = magic_klass objs, options
    File.open(dump_filename(klass, :xml, options), 'w') do |f|
      f << XmlSimple.xml_out(objs, 'KeepRoot' => true)
    end
  end
end

if $ARGV.include?('--dump-all')
  # require 'metropolitan_areas'
  # dump_all  MetropolitanArea.all_metros, [:yaml, :xml, :csv, ]
  # dump_all  CityMetro.cities_to_metros,  [:yaml, [:csv, { :literalize_keys => true }]]
  #

  require 'cities_mapping'
  objs = hash_to_objs(CITIES_MAPPING, CityGeolocation = Struct.new(:city, :state, :airport, :lat, :lng))
  hsh = Hash.zip(objs.map{|city| [city.state, city.city]}, objs)
  dump_all hsh, [:yaml, :xml, :csv]
end
