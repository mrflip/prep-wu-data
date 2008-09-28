# -*- coding: utf-8 -*-
require 'imw'
require 'imw/dataset/datamapper'
require 'dm-types'

#
# Word Frequency
#
module WordFrequency
  PARTS_OF_SPEECH = %w[
    NoC  NoP  Adj  Num  Verb Uncl Adv  Fore Int  Pron Prep
    Conj DetP Lett Det  VMod Neg  Ex   Form Inf  Gen  Err  ClO
  ].map(&:to_sym)

  CONTEXTS = %w[
    spoken written task conv imaginative informative
  ].map(&:to_sym)

  CORPORA = %w[
    bnc
  ].map(&:to_sym)
end


class HeadWord
  include DataMapper::Resource
  property      :id,            Integer,        :serial      => true
  property      :orig,          String,         :length      => 100,    :nullable => false, :default => ''
  property      :text,          String,         :length      => 100,    :nullable => false, :default => ''
  #
  property      :pos,           Enum[*WordFrequency::PARTS_OF_SPEECH]
  has n,        :word_stats
end

class Lemma
  include DataMapper::Resource
  property      :id,            Integer,        :serial      => true
  property      :orig,          String,         :length      => 100,    :nullable => false, :default => ''
  property      :text,          String,         :length      => 100,    :nullable => false, :default => ''
  #
  property      :head,          Integer
  # has n,       :word_stats
end

class WordStats
  property      :corpus,        Enum[*WordFrequency::CORPORA]
  property      :context,       Enum[*WordFrequency::CONTEXTS]
  property      :word_id,       Integer
  property      :word_type,     String
  belongs_to    :head_word
  before :save, :set_corpus;    def set_corpus()    self.corpus    ||= :bnc end
  before :save, :set_word_type; def set_word_type() self.word_type ||= :head end
  #
  property      :freq,          Float
  property      :range,         Float
  property      :disp,          Float
end

class LogLikelihood
  property      :context,       Enum[*WordFrequency::CONTEXTS]
  property      :corpus,        Enum[*WordFrequency::CORPORA]
  property      :word_id,       Integer
  property      :word_type,     String
  belongs_to    :head_word
  before :save, :set_corpus;    def set_corpus()    self.corpus    ||= :bnc end
  before :save, :set_word_type; def set_word_type() self.word_type ||= :head end
  #
  property      :value,         Float
  property      :sign,          Float
end


  # has n,        :credits
  # has n,        :datasets,    :through => :credits
  # has n,        :taggings,                            :child_key => [:tagger_id]
  # has n,        :tags,        :through => :taggings,  :child_key => [:tagger_id]
  # has n,        :taggables,   :through => :taggings,  :child_key => [:tagger_id], :class_name => 'Dataset'

 # 224564 NoC
 # 190171 NoP
 # 127862 Adj
 # 116560 @
 #  60057 Num
 #  38019 Verb
 #  17053 Uncl
 #   9240 Adv
 #   7313 Fore
 #    772 Int
 #    657 Pron
 #    553 Prep
 #    516 Conj
 #    468 DetP
 #    394 Lett
 #    369 Det
 #     99 VMod
 #     62 Neg
 #     16 Ex
 #     10 Form
 #      5 Inf
 #      4 Gen
 #      4 Err
 #      3 ClO



