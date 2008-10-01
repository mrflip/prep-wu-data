# -*- coding: utf-8 -*-
require 'imw'
require 'imw/dataset/datamapper'
require 'dm-types'

#
# Word Frequency
#

class WordFrequencies
  include DataMapper::Resource
  property      :word,          String,  :key => true, :length => 60, :nullable => false, :default => ''
  property      :speaker_id,    Integer, :key => true,                :nullable => false,                 :index => :speaker_event
  property      :event_id,      Integer, :key => true,                :nullable => false,                 :index => :speaker_event
  property      :freq,          Float
  property      :event_freq,    Float
  property      :bnc_freq,      Float
  #
end

class WordUsage
  include DataMapper::Resource
  property      :word,          String,  :key => true, :length => 60, :nullable => false, :default => ''
  property      :speaker_id,    Integer, :key => true,                :nullable => false,                 :index => :speaker_event
  property      :event_id,      Integer, :key => true,                :nullable => false,                 :index => :speaker_event
  property      :order,         Integer, :key => true
  #
end

class Speaker
  include DataMapper::Resource
  property      :id,            Integer,  :serial      => true
  property      :name,          String,  :length => 60, :nullable => false
  #
end

class Event
  include DataMapper::Resource
  property      :id,            Integer, :serial     => true
  property      :name,          String,  :length => 60, :nullable => false
  #
end



