#!/usr/bin/env ruby

require 'rubygems'
require 'rsruby'
require 'wukong'
require 'wukong/and_pig'

# export R_HOME=/usr/lib/R

class TrainMapper < Wukong::Streamer::RecordStreamer
  attr_accessor :r
  def initialize *args
    super(*args)
    @r ||= RSRuby.instance
    r.eval_R('library(VGAM)')
  end

  def process term, dist, *_, &blk
    return if dist.blank?
    data = dist.from_pig_bag.map{|trial| trial.map{|x| x.to_i}}
    return if data.size < 5
    yield [term, term_trials(data.transpose)].flatten
  end

  def term_trials dist
    r.assign('x', dist.first) # sucesses
    r.assign('y', dist.last)  # trials
    r.eval_R('fit <- vglm(x/y ~ 1, beta.ab)')
    beta_a = r.eval_R('as.numeric(Coef(fit)["shape1"])')
    beta_b = r.eval_R('as.numeric(Coef(fit)["shape2"])')
    [expectation(beta_a, beta_b), variance(beta_a, beta_b)]
  end

  def expectation a, b
    a/(a + b)
  end

  def variance a, b
    u = expectation(a,b)
    u*(1 - u)/(a + b + 1.0)
  end

end

class ClassifierScript < Wukong::Script

  def hadoop_recycle_env *args
    env_args = super(*args)
    env_args << %Q{-cmdenv 'R_HOME=/usr/lib/R'}
  end
end

ClassifierScript.new(TrainMapper, nil).run
