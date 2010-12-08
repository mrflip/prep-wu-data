#!/usr/bin/env ruby

require 'rake'
require 'swineherd' ; include Swineherd

Settings.define :influencer_script_path,  :default  => "/home/travis/infochimps-data/social/network/twitter/metrics/stats/user_metrics"
Settings.define :today,                   :required => true, :description => "Today's date"
Settings.define :data_input_dir,          :required => true, :description => "Path to necessary twitter data"
Settings.resolve!

flow = Workflow.new(Settings.flow_id) do

  tweet_flux            = PigScript.new("#{Settings.influencer_script_path}/tweet_flux.pig")
  tweet_flux_breakdown  = PigScript.new("#{Settings.influencer_script_path}/tweet_flux_breakdown.pig")
  assemble_influencer   = PigScript.new("#{Settings.influencer_script_path}/assemble_influencer.pig")
  final_influencer      = PigScript.new("#{Settings.influencer_script_path}/final_influencer_table.pig")

  task :tweet_flux do
    tweet_flux.output  << next_output(:tweet_flux)
    tweet_flux.options  =
      {:twuid   => "#{Settings.data_input_dir}/twitter_user_id",
       :afb     => "#{Settings.data_input_dir}/a_follows_b" }
    tweet_flux.run
  end

  task :tweet_flux_breakdown do
    tweet_flux_breakdown.output << next_output(:tweet_flux_breakdown)
    tweet_flux_breakdown.options =
      {:tweet   => "#{Settings.data_input_dir}/tweet",
       :hashtag => "#{Settings.data_input_dir}/hashtag",
       :smiley  => "#{Settings.data_input_dir}/smiley",
       :url     => "#{Settings.data_input_dir}/tweet_url" }
    tweet_flux_breakdown.run
  end

  task :assemble_influencer => [:tweet_flux, :tweet_flux_breakdown] do
    assemble_influencer.output  << next_output(:assemble_influencer)
    assemble_influencer.options  =
      {:flux    => latest_output(:tweet_flux),
       :break   => latest_output(:tweet_flux_breakdown),
       :degdist => "#{Settings.data_input_dir}/degree_distribution",
       :rank    => "#{Settings.data_input_dir}/pagerank_with_fo" }
    assemble_influencer.run
  end

  task :final_influencer => [:assemble_influencer] do
    final_influencer.output << next_output(:final_influencer)
    final_influencer.options =
      {:today   => Settings.date_input,
       :metrics => latest_output(:assemble_influencer)}
    final_influencer.run
  end



end

flow.work_dir = "/tmp/influencer_metrics"
flow.describe
flow.run(:final_influencer)
