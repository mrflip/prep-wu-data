#!/usr/bin/env ruby
require 'rubygems'
require 'json/ext'
require 'configliere'

Settings.use :commandline, :define
Settings.define :json_keys, :description => "A comma separated list of keys, in the order to be read from source."
# Settings.resolve!

module TSVtoJSON
  
  # def initialize
  #   keys unless Settings.keys.nil?
  # end
  
  def keys
    @keys ||= Settings.json_keys.split(",")
  end
  
  def into_json record, exclude=[]
    json_hash = Hash.new
    keys.each_with_index do |key, index|
      next if exclude.include?(key)
      json_hash[key] = record[index]
    end
    return JSON.generate(json_hash)
  end
  
end
