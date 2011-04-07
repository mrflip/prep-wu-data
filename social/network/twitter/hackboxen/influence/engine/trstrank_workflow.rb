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

icss           = File.join(outputdir, 'influence.icss.json')
trstrank_tsv   = File.join(outputdir, "data", "trstrank")
bzipd_out      = File.join(outputdir, "data", "trstrank_bzip")
metrics_out    = File.join(outputdir, "data", "metrics")

#
# Create icss before anything else happens
#
valid_keys = %w[namespace protocol data_assets code_assets types messages targets]
schema     = options.reject{|k,v| !valid_keys.include?(k)}.to_json
hdfs.open(icss, 'w'){|f| f.puts(schema)}

trstrank = Workflow.new(options['workflow']['id']) do

  #
  # Scripts needed to run trstrank workflow
  #
  templates = File.dirname(__FILE__)+'/templates/trstrank'
  graph_assembler      = PigScript.new(File.join(templates, 'assemble_multigraph.pig.erb'))
  degrees_calculator   = PigScript.new(File.join(templates, 'degree_distribution.pig.erb'))
  pagerank_initializer = PigScript.new(File.join(templates, 'pagerank_initialize.pig.erb'))
  pagerank_iterator    = PigScript.new(File.join(templates, 'pagerank_iterate.pig.erb'))
  followers_joiner     = PigScript.new(File.join(templates, 'join_and_scale.pig.erb'))
  followers_binner     = WukongScript.new(File.join(templates, 'trst_quotient.rb'))
  trstrank_assembler   = PigScript.new(File.join(templates, 'trstrank_assembler.pig.erb'))

  #
  # Take a_follows_b and a_atsigns_b and assemble multigraph
  #
  task :assemble_multigraph do
    graph_assembler.env['PIG_OPTS'] = options['hadoop']['pig_options']
    graph_assembler.attributes = {
      :hdfs              => "hdfs://#{options['hadoop']['hdfs']}",
      :jars              => options['hbase']['jars'],
      :twitter_rel_table => options['hbase']['twitter_rel_table'],
      :reduce_tasks      => options['hadoop']['reduce_tasks'],
      :out               => next_output(:assemble_multigraph)
    }
    graph_assembler.run unless hdfs.exists? latest_output(:assemble_multigraph)
  end

  #
  # Use the multigraph to create initial input for pagerank
  #
  task :pagerank_initialize => [:assemble_multigraph] do
    pagerank_initializer.env['PIG_OPTS'] = options['hadoop']['pig_options']
    pagerank_initializer.attributes = {
      :hdfs         => "hdfs://#{options['hadoop']['hdfs']}",
      :multigraph   => latest_output(:assemble_multigraph),
      :reduce_tasks => options['hadoop']['reduce_tasks'],
      :out          => next_output(:pagerank_initialize)
    }
    pagerank_initializer.run unless hdfs.exists? latest_output(:pagerank_initialize)
  end


  #
  # Iterate pagerank multiple times over the multigraph
  #
  task :pagerank_iterate => [:pagerank_initialize] do
    pagerank_iterator.env['PIG_OPTS'] = options['hadoop']['pig_options']
    pagerank_iterator.attributes = {
      :hdfs              => "hdfs://#{options['hadoop']['hdfs']}",
      :reduce_tasks      => options['hadoop']['reduce_tasks'],
      :pagerank_damping  => options['trstrank']['damping'],
      :current_iteration => latest_output(:pagerank_initialize)
    }
    options['trstrank']['iterations'].to_i.times do
      pagerank_iterator.attributes[:next_iteration]     = next_output(:pagerank_iterate)
      pagerank_iterator.run unless hdfs.exists? latest_output(:pagerank_iterate)
      pagerank_iterator.refresh!
      pagerank_iterator.attributes[:current_iteration] = latest_output(:pagerank_iterate)
    end
  end


  #
  # Calculate the degree distribution of the multigraph
  #
  task :multigraph_degrees => [:assemble_multigraph] do
    degrees_calculator.env['PIG_OPTS'] = options['hadoop']['pig_options']
    degrees_calculator.attributes = {
      :hdfs                => "hdfs://#{options['hadoop']['hdfs']}",
      :reduce_tasks        => options['hadoop']['reduce_tasks'],
      :multigraph          => latest_output(:assemble_multigraph),
      :degree_distribution => next_output(:multigraph_degrees)
    }
    degrees_calculator.run unless hdfs.exists? latest_output(:multigraph_degrees)
  end

  #
  # FIXME!!!!
  #
  def hackety_exists? target
    system %Q{hadoop fs -test -e #{target}}
  end

  task :store_valuable_graph_data => [:multigraph_degrees, :pagerank_iterate] do
    deg_dist_out   = File.join(options['workflow']['s3_graph_dir'], options['workflow']['id'].to_s, 'degree_distribution')
    multigraph_out = File.join(options['workflow']['s3_graph_dir'], options['workflow']['id'].to_s, 'multigraph')
    last_pagerank  = File.join(options['workflow']['s3_graph_dir'], options['workflow']['id'].to_s, 'last_pagerank')
    hdfs.stream(latest_output(:multigraph_degrees), deg_dist_out)    unless hackety_exists? deg_dist_out
    hdfs.stream(latest_output(:assemble_multigraph), multigraph_out) unless hackety_exists? multigraph_out
    hdfs.stream(latest_output(:pagerank_iterate), last_pagerank)     unless hackety_exists? last_pagerank
  end
  #
  #
  #

  #
  # Scales final pagerank values to (0-10) and joins it with the followers
  # observed.
  #
  # FIXME: why doesn't multitask work here?
  #
  # multitask :join_pagerank_with_followers => [:multigraph_degrees, :pagerank_iterate] do
  task :join_pagerank_with_followers => [:store_valuable_graph_data] do
    followers_joiner.env['PIG_OPTS'] = options['hadoop']['pig_options']
    followers_joiner.attributes = {
      :hdfs                => "hdfs://#{options['hadoop']['hdfs']}",
      :reduce_tasks        => options['hadoop']['reduce_tasks'],
      :pig_home            => options['hadoop']['pig_home'],
      :degree_distribution => latest_output(:multigraph_degrees),
      :pagerank_output     => latest_output(:pagerank_iterate),
      :out                 => next_output(:join_pagerank_with_followers)
    }
    followers_joiner.run unless hdfs.exists? latest_output(:join_pagerank_with_followers)
  end


  #
  # Bin users by followers observed and get percentiles
  #
  task :trstquotient => [:join_pagerank_with_followers] do
    followers_binner.output << next_output(:trstquotient)
    followers_binner.input  << latest_output(:join_pagerank_with_followers)
    followers_binner.options = {
      :forank_table => File.join(templates, 'forank_table.rb'),
      :atrank_table => File.join(templates, 'atrank_table.rb')
    }
    followers_binner.run unless hdfs.exists? latest_output(:trstquotient)
  end


  #
  # Assemble all the components to form final trstrank table.
  #
  task :assemble_trstrank => [:trstquotient] do
    trstrank_assembler.env['PIG_OPTS']      = options['hadoop']['pig_options']
    trstrank_assembler.env['PIG_CLASSPATH'] = options['hadoop']['pig_classpath']
    trstrank_assembler.attributes = {
      :jars           => options['hbase']['jars'],
      :hdfs           => "hdfs://#{options['hadoop']['hdfs']}",
      :twuid_table    => options['hbase']['twitter_users_table'],
      :reduce_tasks   => options['hadoop']['reduce_tasks'],
      :twuid_cf       => options['hbase']['twitter_users_cf'],
      :rank_with_tq   => latest_output(:trstquotient),
      :tsv_version    => trstrank_tsv
    }
    trstrank_assembler.run unless hdfs.exists? trstrank_tsv
  end

  task :package_trstrank => [:assemble_trstrank] do
    hdfs.bzip(trstrank_tsv, bzipd_out) unless hdfs.exists? bzipd_out
  end

  task :send_trstrank_to_its_final_resting_place_in_the_cloud => [:package_trstrank] do
    adorned = "trstrank_#{options['workflow']['id']}.tsv.bz2"
    output  = File.join(options['trstrank']['final_resting_place_in_the_cloud'], adorned)
    input   = File.join(bzipd_out, "part-00000.bz2")
    cmd     = "hadoop fs -cp #{input} #{output}"
    sh cmd unless hackety_exists?(output)
  end

end

trstrank.workdir = File.join(inputdir, "rawd")
trstrank.run(:send_trstrank_to_its_final_resting_place_in_the_cloud)
