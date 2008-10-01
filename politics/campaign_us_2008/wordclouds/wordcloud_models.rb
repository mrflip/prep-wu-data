# -*- coding: utf-8 -*-
require 'imw'
require 'imw/dataset/datamapper'
require 'dm-types'

#
# Word Frequency
#

class WordFreq
  include DataMapper::Resource
  property      :word,          String,  :key => true, :length => 60, :nullable => false
  property      :speaker_id,    Integer, :key => true,                :nullable => false
  property      :event_id,      Integer, :key => true,                :nullable => false
  property      :freq,          Float
  property      :event_freq,    Float
  property      :bnc_freq,      Float
  #
end

class WordUsage
  include DataMapper::Resource
  property      :speaker_id,    Integer, :key => true,                :nullable => false
  property      :event_id,      Integer, :key => true,                :nullable => false
  property      :word_order,    Integer, :key => true
  #
  property      :para,          Integer
  property      :raw_word,      String,                 :length => 60, :nullable => false
  property      :norm_word,     String,                 :length => 60, :nullable => false, :index => :norm_word
  #
  def self.make speaker, event, raw_word, norm_word, para, word_order
    update_or_create({ :speaker_id => speaker.id, :event_id => event.id, :word_order => word_order, },
      { :raw_word => raw_word, :norm_word => norm_word, :para => para, })
  end
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
  property      :date,          Date,                   :nullable => false
  property      :site,          String,  :length => 60, :nullable => false
  property      :city,          String,  :length => 60, :nullable => false
  property      :state,         String,  :length => 2,  :nullable => false
  property      :country,       String,  :length => 2,  :nullable => false
  #
end



