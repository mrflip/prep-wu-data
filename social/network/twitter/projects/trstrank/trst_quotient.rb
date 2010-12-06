#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'configliere' ; Configliere.use(:commandline, :env_var, :define)

Settings.define :atrank_table
Settings.define :forank_table
Settings.resolve!

require Settings.atrank_table
require Settings.forank_table

Float.class_eval do def round_to(x) ((10**x)*self).round.to_f/(10**x) end ; end
#
# Warning! Need to use the same method of binning users
# here as we do in the binning_percentile_estimator
#
class Mapper < Wukong::Streamer::RecordStreamer

  def process *args
    uid, fo_rank, at_rank, obs_followers = args
    fo_rank = fo_rank.to_f.round_to(1)
    at_rank = at_rank.to_f.round_to(1)

    # Fetch rows for each of follow percentiles and atsign percentiles from table
    fo_bin  = FORANK_TABLE[casebin(logbin(obs_followers.to_f))]
    at_bin  = ATRANK_TABLE[casebin(logbin(obs_followers.to_f))]

    return if fo_bin.blank?
    return if at_bin.blank?

    #
    # FIXME: this is obviously NOT the right linear combination
    #
    rank = 0.5*fo_rank      + 0.5*at_rank
    tq   = 0.5*fo_bin[fo_rank] + 0.5*at_bin[at_rank]
    #
    #
    #
    yield [uid, rank, tq]
  end

  def logbin(x)
    begin
      Math.log10(x.to_f).round_to(1)*10
    rescue
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

Wukong::Script.new(Mapper, nil).run
