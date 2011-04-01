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
options = YAML.load(hdfs.open(File.join(outputdir, "env", "working_environment.yaml")).read)

metrics = Workflow.new(options['workflow']['id']) do

  #
  # Scripts needed to run metrics workflow
  #
  templates = File.dirname(__FILE__)+'/templates/metrics'
  
  tweet_flux            = PigScript.new(File.join(templates, "tweet_flux.pig.erb"))
  tweet_flux_breakdown  = PigScript.new(File.join(templates, "tweet_flux_breakdown.pig.erb"))
  assemble_influencer   = PigScript.new(File.join(templates, "assemble_influencer.pig.erb"))
  final_influencer      = PigScript.new(File.join(templates, "final_influencer_table.pig"))
  fix_inconsistencies   = WukongScript.new(File.join(templates, "fix_inconsistencies.rb"))

  task :tweet_flux do
    tweet_flux.env['PIG_OPTS'] = options['hadoop']['pig_options']
    tweet_flux.attributes  = {
      :jars              => options['hbase']['jars'],
      :twuid_table       => options['hbase']['twitter_users_table'],
      :twuid_cf          => options['hbase']['twitter_users_cf'],
      :twitter_rel_table => options['hbase']['twitter_rel_table'],
      :reduce_tasks      => options['hadoop']['reduce_tasks'],
      :hdfs              => "hdfs://#{options['hadoop']['hdfs']}",
      :out               => next_output(:tweet_flux)
    }
    tweet_flux.run unless hdfs.exists? latest_output(:tweet_flux)
  end

  task :tweet_flux_breakdown do
    tweet_flux_breakdown.env['PIG_OPTS'] = options['hadoop']['pig_options']
    tweet_flux_breakdown.attributes = {
      :jars         => options['hbase']['jars'],
      :hdfs         => "hdfs://#{options['hadoop']['hdfs']}",
      :out          => next_output(:tweet_flux_breakdown),
      :tweet_table  => options['hbase']['twitter_tweet_table'],
      :token_table  => options['hbase']['twitter_token_table'],
      :reduce_tasks => options['hadoop']['reduce_tasks']
    }
    tweet_flux_breakdown.run unless hdfs.exists? latest_output(:tweet_flux_breakdown)
  end

  #
  # This is kind of hackety. 'next_output' for these will be the 'latest_output' from the trstrank calc
  # if it was run on the same machine with the same flow id. This way, if trstrank was ran first the data
  # will be streamed to s3, but not streamed back over for this task since its already here. Otherwise it
  # is streamed over.
  #
  task :get_valuable_graph_data do
    deg_dist_out   = File.join(options['workflow']['s3_graph_dir'], options['workflow']['id'].to_s, 'degree_distribution')
    multigraph_out = File.join(options['workflow']['s3_graph_dir'], options['workflow']['id'].to_s, 'multigraph')
    last_pagerank  = File.join(options['workflow']['s3_graph_dir'], options['workflow']['id'].to_s, 'last_pagerank')
    hdfs.stream(deg_dist_out,   next_output(:multigraph_degrees))  unless hdfs.exists? latest_output(:multigraph_degrees)
    hdfs.stream(multigraph_out, next_output(:assemble_multigraph)) unless hdfs.exists? latest_output(:assemble_multigraph)

    # this one is really hackety
    options['trstrank']['iterations'].to_i.times{next_output(:pagerank_iterate)}
    hdfs.stream(last_pagerank, latest_output(:pagerank_iterate)) unless hdfs.exists? latest_output(:pagerank_iterate)
  end
  
  task :assemble_influencer => [:get_valuable_graph_data, :tweet_flux, :tweet_flux_breakdown] do
    assemble_influencer.env['PIG_OPTS'] = options['hadoop']['pig_options']
    assemble_influencer.attributes = {
      :jars                => options['hbase']['jars'],
      :hdfs                => "hdfs://#{options['hadoop']['hdfs']}",
      :out                 => next_output(:assemble_influencer),
      :twuid_table         => options['hbase']['twitter_users_table'],
      :degree_distribution => latest_output(:multigraph_degrees),
      :tweet_flux          => latest_output(:tweet_flux),
      :break_down          => latest_output(:tweet_flux_breakdown),
      :latest_rank         => latest_output(:pagerank_iterate),
      :reduce_tasks        => options['hadoop']['reduce_tasks']
    }
    assemble_influencer.run unless hdfs.exists? latest_output(:assemble_influencer)
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
metrics.run(:tweet_flux)
