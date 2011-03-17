#!/usr/bin/env ruby

require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script

Settings.define :flow_id,                 :required => true, :description => "Workflow needs a unique numeric id"
Settings.define :data_input_dir,          :required => true, :description => "Path to necessary twitter data"
Settings.define :reduce_tasks,            :default  => 96,   :description => "Change to reduce task capacity on cluster"
Settings.define :influencer_script_path,  :default  => "/home/travis/infochimps-data/social/network/twitter/metrics/stats/user_metrics"
Settings.resolve!

flow = Workflow.new(Settings.flow_id) do

  tweet_flux            = PigScript.new("#{Settings.influencer_script_path}/tweet_flux.pig")
  tweet_flux_breakdown  = PigScript.new("#{Settings.influencer_script_path}/tweet_flux_breakdown.pig")
  assemble_influencer   = PigScript.new("#{Settings.influencer_script_path}/assemble_influencer.pig")
  final_influencer      = PigScript.new("#{Settings.influencer_script_path}/final_influencer_table.pig")
  fix_inconsistencies   = WukongScript.new("#{Settings.influencer_script_path}/fix_inconsistencies.rb")

  task :tweet_flux do
    tweet_flux.output  << next_output(:tweet_flux)
    tweet_flux.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    tweet_flux.options  = {
      :twuid   => "#{Settings.data_input_dir}/twitter_user_id",
      :afb     => "#{Settings.data_input_dir}/a_follows_b",
      :twflux  => latest_output(:tweet_flux)
    }
    tweet_flux.run
  end

  task :tweet_flux_breakdown do
    tweet_flux_breakdown.output << next_output(:tweet_flux_breakdown)
    tweet_flux_breakdown.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    tweet_flux_breakdown.options = {
      :tweet   => "#{Settings.data_input_dir}/tweet",
      :hashtag => "#{Settings.data_input_dir}/hashtag",
      :smiley  => "#{Settings.data_input_dir}/smiley",
      :url     => "#{Settings.data_input_dir}/tweet_url",
      :break   => latest_output(:tweet_flux_breakdown)
    }
    tweet_flux_breakdown.run
  end

  task :assemble_influencer => [:tweet_flux, :tweet_flux_breakdown] do
    assemble_influencer.output  << next_output(:assemble_influencer)
    assemble_influencer.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    assemble_influencer.options  = {
      :flux    => latest_output(:tweet_flux),
      :break   => latest_output(:tweet_flux_breakdown),
      :degdist => "#{Settings.data_input_dir}/degree_distribution",
      :rank    => "#{Settings.data_input_dir}/scaled_pagerank_with_fo",
      :metrics => latest_output(:assemble_influencer)
    }
    assemble_influencer.run
  end

  task :final_influencer => [:assemble_influencer] do
    today = (`wu-date`).strip
    final_influencer.output << next_output(:final_influencer)
    final_influencer.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    final_influencer.options = {
      :today         => "#{today}l",
      :metrics       => latest_output(:assemble_influencer),
      :metrics_table => latest_output(:final_influencer)
    }
    final_influencer.run
  end

  task :fix_inconsistencies => [:final_influencer] do
    fix_inconsistencies.input  << latest_output(:final_influencer)
    fix_inconsistencies.output << next_output(:fix_inconsistencies)
  end

end

flow.workdir = "/tmp/influencer_metrics"
flow.describe
flow.run(Settings.rest.first)
# flow.clean!
