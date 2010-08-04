#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'

require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model

module TweetSampler
  
  class Mapper < Wukong::Streamer::StructStreamer

    def process tweet, *args
      yield [tweet.created_at, tweet.text] if tweet.id
    end

  end

  class Reducer < Wukong::Streamer::AccumulatingReducer

    attr_accessor :sampling_rate, :tweets

    alias_method :date, :key

    def initialize options
      super(options)
      self.sampling_rate = (options[:sampling_rate] && options[:sampling_rate].to_f) || 0.00001 # ~230K tweets
    end
    
    def start! *args
      self.tweets = []
    end

    def accumulate *args, &block
      tweets << args.last
    end

    def finalize
      tweets.each do |tweet|
        yield tweet if rand < sampling_rate
      end
    end
  end
  
end

Wukong::Script.new(TweetSampler::Mapper, TweetSampler::Reducer).run

