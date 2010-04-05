#!/usr/bin/env ruby

#ANNYOING PROBLEMS

# IF there are too many properties of type 'text'
# then everything falls apart
# How many is too many? 3 apparently

require 'rubygems'
require 'dm-core'

DataMapper.setup(:default, 'mysql://localhost/msds')

class Msds
  include DataMapper::Resource
  property :id,      Serial
  has n, :sections
end

class Section
  include DataMapper::Resource
  property :id,      Serial
  property :title,   String
  property :content, Text
  belongs_to :msds
end

DataMapper.auto_migrate!

sheet = Msds.new
sheet.sections.new( :title => 'test', :content => 'nonsense' )
sheet.save
