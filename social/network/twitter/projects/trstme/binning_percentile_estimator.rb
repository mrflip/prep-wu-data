#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'wukong/streamer/count_keys'
require 'rsruby'

Float.class_eval do def round_to(x) ((10**x)*self).round.to_f/(10.0**x) end ; end
Array.class_eval do

  #
  # Count number of elements in self less than x
  #
  def num_less_than x
    self.inject(0){|count,y| count += 1 if y < x; count}
  end

  #
  # Count number of occurrences of x
  #
  def frequency_of x
    self.inject(0){|count,y| count += 1 if x == y; count}
  end

  #
  # Return percentile with interpolation
  #
  def percentile x
    ((self.num_less_than(x) + 0.5*self.frequency_of(x))/self.size.to_f)*100.0
  end

  #
  # Return an array of percentiles, one for each element of self
  #
  def percentiles
    self.map{|x| self.percentile(x)}
  end

  #
  # Pass in an r instance, returns quantiles
  #
  def r_percentiles r
    seq = r.seq({'from' => 0, 'to' => 1, 'length' => self.uniq.length})
    r.assign('x', self)
    r.assign('s', seq)
    q = r.eval_R('quantile(x, probs=s)')
    q.each{|k,v| q[k] = v.to_f.round_to(1)}
    q = q.invert
    q.each{|k,v| q[k] = v.gsub("%","").to_f} # comes back with "%" in the percentiles
  end

  def pairs
    self.zip(self[1..-1]).reject{|x| x.blank? || x.include?(nil)}
  end

end

#
# Do nothing more than bin users here, arbitrary and probably bad
#
class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    uid, rank, followers = args
    yield [casebin(logbin(followers)), rank]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)*10
    rescue Errno::ERANGE
      return 0.01
    end
  end

  #
  # Voodoo
  #
  def casebin x
    x = x.to_f
    return x if x < 20.0
    return 25.0 if x < 25.0
    return 30.0 if x < 30.0
    return 31.0
  end

end

#
# Calculate percentile rank for every pr value in a given follower bracket
#
class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :binned_percentiles, :single_bin, :r

  def initialize *args
    super(*args)
    self.r ||= RSRuby.instance
    self.binned_percentiles ||= {}
  end

  def start! bin, rank, *_
    self.single_bin = []
  end

  def accumulate bin, rank, *_
    rank = rank.to_f.round_to(1)
    self.single_bin << rank
  end

  def finalize
    self.binned_percentiles[key.to_i] = generate_all_pairs
  end

  #
  # Shell out to r where appropriate
  #
  def percentiles
    q = single_bin.r_percentiles(r)
    q[0.0]  ||= 0.0
    q[10.0] ||= 100.0
    q.to_a.sort!{|x,y| x.first <=> y.first}
  end

  #
  # Write the final table to disk as a ruby hash
  #
  def after_stream
    table = File.open("trstrank_table.rb", 'w')
    table << "TRSTRANK_TABLE = " << binned_percentiles.inspect
    table.close
  end

  #
  # Generate a hash of all pairs {trstrank => percentile, ...}, interpolate when necessary
  #
  def generate_all_pairs
    h = {}
    percentiles.pairs.each do |pairs|
      interpolate(pairs.first, pairs.last, 0.1).each{|point| h[point.first] = point.last}
    end
    h
  end

  #
  # Nothing to see here, move along
  #
  def interpolate pair1, pair2, dx
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
