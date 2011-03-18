#!/usr/bin/env jruby

require 'rubygems'
require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script'
require 'json'

inputdir  = ARGV[0]
outputdir = ARGV[1]

hdfs = Swineherd::FileSystem.get(:hdfs)

#
# Read in working config file
#
options       = YAML.load(hdfs.open(File.join(outputdir, "env", "working_environment.yaml")).read)

metrics = Workflow.new(options['workflow']['id']) do

  #
  # Scripts needed to run metrics workflow
  #
  templates = File.dirname(__FILE__)+'/templates/metrics'
  
  tweet_flux            = PigScript.new(File.join(templates, "tweet_flux.pig"))
  tweet_flux_breakdown  = PigScript.new(File.join(templates, "tweet_flux_breakdown.pig"))
  assemble_influencer   = PigScript.new(File.join(templates, "assemble_influencer.pig"))
  final_influencer      = PigScript.new(File.join(templates, "final_influencer_table.pig"))
  fix_inconsistencies   = WukongScript.new(File.join(templates, "fix_inconsistencies.rb"))

  task :tweet_flux do
    # FIXME, needs to pull users table from hbase

    
    # tweet_flux.env['PIG_OPTS'] = options['hadoop']['pig_options']
    # tweet_flux.options  = {
    #   :twuid   => "#{Settings.data_input_dir}/twitter_user_id",
    #   :afb     => "#{Settings.data_input_dir}/a_follows_b",
    #   :twflux  => latest_output(:tweet_flux)
    # }
    # tweet_flux.run
  end

  task :tweet_flux_breakdown do
    # tweet_flux_breakdown.options = {
    #   :tweet   => "#{Settings.data_input_dir}/tweet",
    #   :hashtag => "#{Settings.data_input_dir}/hashtag",
    #   :smiley  => "#{Settings.data_input_dir}/smiley",
    #   :url     => "#{Settings.data_input_dir}/tweet_url",
    #   :break   => latest_output(:tweet_flux_breakdown)
    # }
    # tweet_flux_breakdown.run
  end

  task :assemble_influencer => [:tweet_flux, :tweet_flux_breakdown] do
    # assemble_influencer.output  << next_output(:assemble_influencer)
    # assemble_influencer.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    # assemble_influencer.options  = {
    #   :flux    => latest_output(:tweet_flux),
    #   :break   => latest_output(:tweet_flux_breakdown),
    #   :degdist => "#{Settings.data_input_dir}/degree_distribution",
    #   :rank    => "#{Settings.data_input_dir}/scaled_pagerank_with_fo",
    #   :metrics => latest_output(:assemble_influencer)
    # }
    # assemble_influencer.run
  end

  task :final_influencer => [:assemble_influencer] do
    # today = (`wu-date`).strip
    # final_influencer.output << next_output(:final_influencer)
    # final_influencer.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    # final_influencer.options = {
    #   :today         => "#{today}l",
    #   :metrics       => latest_output(:assemble_influencer),
    #   :metrics_table => latest_output(:final_influencer)
    # }
    # final_influencer.run
  end

  task :fix_inconsistencies => [:final_influencer] do
    # fix_inconsistencies.input  << latest_output(:final_influencer)
    # fix_inconsistencies.output << next_output(:fix_inconsistencies)
  end

end

metrics.workdir = File.join(inputdir, "rawd")
metrics.run(:fix_inconsistencies)
