require 'rubygems'
require 'wukong'

module TweetSampler

  class Mapper < Wukong::Streamer::StructStreamer

    def process tweet, *args
      yield [tweet.created_at.to_i / 1_000_000, tweet.text] # by day
    end

  end

  class Reducer < Wukong::Streamer::AccumulatingReducer

    attr_accessor :sampling_rate, :tweets

    alias_method :key, :date

    def initialize options
      super(options)
      self.sampling_rate = options[:sampling_rate] || 0.00001 # ~23K tweets
    end
    
    def start! *args
      self.tweets = []
    end

    def accumulate *args, &block
      tweets << args.last
    end

    def finalize
      tweets.each do |tweet|
        yield tweet if rand > sampling_rate
      end
    end
  end
  
end

Wukong::Script.new(TweetSampler::Mapper, TweetSampler::Reducer).run

