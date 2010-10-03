#!/usr/bin/env ruby

$: << File.dirname(__FILE__)
require 'rubygems'
require 'wukong'
require 'trstrank_table'

Float.class_eval do def round_to(x) ((10**x)*self).round.to_f/(10**x) end ; end

#
# Warning! Need to use the same method of binning users
# here as we do in the binning_percentile_estimator
#
class Mapper < Wukong::Streamer::RecordStreamer
  def process *args
    return unless args.length == 3
    uid, fo_rank, at_rank, obs_followers = args
    fo_rank = fo_rank.to_f.round_to(1)
    at_rank = at_rank.to_f.round_to(1)
    fo_bin  = FORANK_TABLE["#{logbin(obs_followers)}"]
    at_bin  = ATRANK_TABLE["#{logbin(obs_followers)}"]
    return if fo_bin.blank?
    return if at_bin.blank?
    #
    # FIXME: this is obviously NOT the right linear combination
    #
    rank = 0.5*fo_rank      + 0.5*at_rank
    tq   = 0.5*fo_bin[rank] + 0.5*at_bin[rank]
    #
    #
    #
    yield [uid, rank, tq]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)*10
    rescue Errno::ERANGE
      return 0.01
    end
  end

end

Wukong::Script.new(Mapper, nil).run
