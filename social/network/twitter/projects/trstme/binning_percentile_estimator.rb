#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wukong/streamer/count_keys'

Float.class_eval do def round_to(x) ((10**x)*self).round end ; end



#
# Do nothing more than bin users here, arbitrary and probably bad
#
class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    rank, followers = args
    yield [logbin(followers), rank]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)
    rescue Errno::ERANGE
      return 0.01
    end
  end

end


#
# Calculate percentile rank for every pr value in a given follower bracket
#
class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :count_bin
  def start! *args
    return unless args.length == 2
    self.count_bin          ||= {}
    self.count_bin[args[0]] ||= {}
  end

  def accumulate *args
    return unless args.length == 2
    bin, rank = args
    rank = (rank.to_f*10.0).round.to_f/10.0
    self.count_bin ||= {}
    self.count_bin[bin] ||= {}
    self.count_bin[bin][rank] ||= 0
    self.count_bin[bin][rank] += 1
  end

  def finalize
    count_bin[key] = generate_all_pairs(key).inject({}){|h,pair| h[pair.first] = pair.last; h}
    # yield [key, count_bin[key].values.sort.join(",")]
  end

  #
  # Write the final table to disk as a ruby hash
  #
  def after_stream
    table = File.open("trstrank_table.rb", 'w')
    table << "TRSTRANK_TABLE = " << count_bin.inspect
    table.close
  end

  #
  # Return percentile of a given trstrank for a given follower bracket
  #
  def percentile bin, rank
    ((count_less_than(bin,rank) + 0.5*frequency_of(bin,rank))/ total_num(bin) )*100.0
  end

  #
  # Return the count of values less than rank
  #
  def count_less_than bin, rank
    count_bin[bin].keys.inject(0){|count,key| count += count_bin[bin][key] if key.to_f < rank; count}
  end

  #
  # Return the count of rank
  #
  def frequency_of bin, rank
    count_bin[bin].keys.inject(0){|count,key| count += count_bin[bin][key] if key.to_f == rank; count}
  end

  #
  # Return the total number in sample
  #
  def total_num bin
    count_bin[bin].values.inject(0){|count,v| count += v; count}
  end

  #
  # Generate a list of all pairs {trstrank => percentile}, interpolate when necessary
  #
  def generate_all_pairs bin
    h = {}
    count_bin[bin].keys.each do |rank|
      h[rank.to_f] = percentile(bin, rank.to_f)
    end
    h[0.0]  ||= 0.0
    h[10.0] ||= 100.0
    arr      = h.to_a.sort!{|x,y| x.first <=> y.first}
    list     = arr.zip(arr[1..-1])
    big_list = []
    big_list << [0.0,0.0]
    list.each do |pairs|
      interpolate(pairs.first, pairs.last, 0.1).each{|pair| big_list << pair}
    end
    big_list.uniq.sort{|x,y| x.first <=> y.first}
  end


  #
  # Nothing to see here, move along
  #
  def interpolate pair1, pair2, dx
    return [pair1] if pair2.blank?
    m   = (pair2.last - pair1.last)/(pair2.first - pair1.first) # slope
    b   = pair2.last - m*pair2.first                            # y intercept
    num = ((pair2.first - pair1.first)/dx).abs.round            # number of points to interpolate
    points = []
    num.times do |i|
      x = pair1.first + (i+1).to_f*dx
      y = m*x + b
      points << [x,y]
    end
    points                                                       # return an array of pairs
  end

end

Wukong::Script.new(Mapper,Reducer).run
