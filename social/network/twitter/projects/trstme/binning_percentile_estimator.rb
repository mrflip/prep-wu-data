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
    rank, followers = args
    yield [logbin(followers), rank]
    # yield [casebin(followers), rank]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)*10
    rescue Errno::ERANGE
      return 0.01
    end
  end

  def casebin x
    x = x.to_f
    return 0 if x < 1
    return 1 if x < 2
    return 2 if x < 3
    return 3 if x < 4
    return 4
    # and so on
    #return 'foofuckingbar'
  end

end


#
# Calculate percentile rank for every pr value in a given follower bracket
#
class Reducer < Wukong::Streamer::AccumulatingReducer
  attr_accessor :rank_hist, :r

  def initialize *args
    super(*args)
    self.r ||= RSRuby.instance
  end
  
  def start! bin, rank, *_
    self.rank_hist      ||= {}
    self.rank_hist[bin] ||= []
  end

  def accumulate bin, rank, *_
    rank = rank.to_f.round_to(1)
    self.rank_hist[bin] << rank
  end

  def finalize
    # self.rank_hist[key] = generate_all_pairs(key).inject({}){|h,pair| h[pair.first] = pair.last; h}
    # yield [key, rank_hist[key].join(",")]
    # yield [key, rank_hist[key].percentiles.join(',')]
    p generate_all_pairs(key)
  end

  def percentiles bin
    q = rank_hist[bin].r_percentiles(r)
    q[0.0]  ||= 0.0
    q[10.0] ||= 100.0
    q.to_a.sort!{|x,y| x.first <=> y.first}
  end
  
  # #
  # # Write the final table to disk as a ruby hash
  # #
  # def after_stream
  #   table = File.open("trstrank_table.rb", 'w')
  #   table << "TRSTRANK_TABLE = " << rank_hist.inspect
  #   table.close
  # end
  # 
  #
  # Generate a list of all pairs {trstrank => percentile}, interpolate when necessary
  #
  
  def generate_all_pairs bin
    percentiles(bin).pairs
    # list.each do |pairs|
    #   interpolate(pairs.first, pairs.last, 0.1).each{|pair| big_list << pair}
    # end
    # big_list.uniq.sort{|x,y| x.first <=> y.first}
  end
  # 
  # 
  # #
  # # Nothing to see here, move along
  # #
  # def interpolate pair1, pair2, dx
  #   return [pair1] if pair2.blank?
  #   m   = (pair2.last - pair1.last)/(pair2.first - pair1.first) # slope
  #   b   = pair2.last - m*pair2.first                            # y intercept
  #   num = ((pair2.first - pair1.first)/dx).abs.round            # number of points to interpolate
  #   points = []
  #   num.times do |i|
  #     x = pair1.first + (i+1).to_f*dx
  #     y = m*x + b
  #     points << [x,y]
  #   end
  #   points                                                       # return an array of pairs
  # end

end

Wukong::Script.new(Mapper,Reducer).run
