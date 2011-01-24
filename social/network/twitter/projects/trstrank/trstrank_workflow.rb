require 'rubygems'
require 'swineherd' ; include Swineherd

Settings.define :flow_id,    :required => true,                 :description => "Flow id required to make run of workflow unique"
Settings.define :input_dir,  :required => true,                 :description => "HDFS directory where input data lives (a_follows_b and a_atsigns_b)"
Settings.define :iterations,     :default => 10, :type => Integer, :description => "Number of pagerank iterations to run"
Settings.define :ics_tw_scripts, :default => "/home/jacob/Programming/infochimps-data/social/network/twitter"
Settings.define :pig_opts,       :env_var => 'PIG_OPTS'
Settings.resolve!

#
# USAGE:
#
# ./trsrank_workflow.rb --flow_id=201012 --input_dir=/tmp/streamed --pig_opts="-Dmapred.reduce.tasks=100"
#
# INPUT:
#
# a_follows_b, a_atsigns_b, twitter_user_id
#
# OUTPUT (stream these to s3):
#
# multi_edge:     latest output of 'assemble_multigraph' (assemble_multigraph-0) 
# degree_dist:    latest output of 'multigraph_degrees' (multigraph_degrees-0)
# trstrank_table: latest output of 'assemble_trstrank' (assemble_trstrank-0)
#
#
flow = Workflow.new(Settings.flow_id) do

  #
  # Scripts needed to run trstrank workflow
  #
  graph_assembler      = WukongScript.new("#{Settings.ics_tw_scripts}/base/graph/multigraph/assemble_multigraph.rb")
  degrees_calculator   = PigScript.new("#{Settings.ics_tw_scripts}/base/graph/multigraph/multigraph_degrees.pig")
  pagerank_iterator    = PigScript.new("#{Settings.ics_tw_scripts}/base/graph/pagerank/dual_valued/dual_valued_pagerank.pig")
  pagerank_initializer = PigScript.new("#{Settings.ics_tw_scripts}/base/graph/pagerank/dual_valued/dual_valued_initialize.pig")
  followers_joiner     = PigScript.new("#{Settings.ics_tw_scripts}/projects/trstrank/join_pr_with_followers.pig")
  followers_binner     = WukongScript.new("#{Settings.ics_tw_scripts}/projects/trstrank/trst_quotient.rb")
  trstrank_assembler   = PigScript.new("#{Settings.ics_tw_scripts}/projects/trstrank/trstrank_assembler.pig")

  #
  # Take a_follows_b and a_atsigns_b and assemble multigraph
  #
  task :assemble_multigraph do
    graph_assembler.output << next_output(:assemble_multigraph)
    graph_assembler.input << "#{Settings.input_dir}/a_follows_b"
    graph_assembler.input << "#{Settings.input_dir}/a_atsigns_b"
    graph_assembler.run
  end

  #
  # Use the multigraph to create initial input for pagerank
  #
  task :pagerank_initialize => [:assemble_multigraph] do 
    pagerank_initializer.output << next_output(:pagerank_initialize)
    pagerank_initializer.options     = {:multi => latest_output(:assemble_multigraph), :out => latest_output(:pagerank_initialize)}
    pagerank_initializer.pig_options = Settings.pig_opts
    pagerank_initializer.run
  end

  #
  # Iterate pagerank multiple times over the multigraph
  #
  task :pagerank_iterate => [:pagerank_initialize] do
    pagerank_iterator.options[:damp]           = '0.85f'
    pagerank_iterator.pig_options              = Settings.pig_opts
    pagerank_iterator.options[:curr_iter_file] = latest_output(:pagerank_initialize)
    Settings.iterations.times do
      pagerank_iterator.output                   << next_output(:pagerank_iterate)
      pagerank_iterator.options[:next_iter_file] = latest_output(:pagerank_iterate)
      pagerank_iterator.run
      pagerank_iterator.refresh!
      pagerank_iterator.options[:curr_iter_file] = latest_output(:pagerank_iterate)
    end
  end

  #
  # Calculate the degree distribution of the multigraph
  #
  task :multigraph_degrees => [:assemble_multigraph] do
    degrees_calculator.pig_options = Settings.pig_opts
    degrees_calculator.output << next_output(:multigraph_degrees)
    degrees_calculator.options = {:degree => latest_output(:multigraph_degrees), :graph => latest_output(:assemble_multigraph)}
    degrees_calculator.run
  end

  #
  # Scales final pagerank values to (0-10) and joins it with the followers
  # observed.
  #
  # FIXME: why doesn't multitask work here?
  #
  # multitask :join_pagerank_with_followers => [:multigraph_degrees, :pagerank_iterate] do
  task :join_pagerank_with_followers => [:multigraph_degrees, :pagerank_iterate] do
    followers_joiner.pig_options = Settings.pig_opts
    followers_joiner.output << next_output(:join_pagerank_with_followers)
    followers_joiner.options = {
      :dist    => latest_output(:multigraph_degrees),
      :out     => latest_output(:join_pagerank_with_followers),
      :prgraph => latest_output(:pagerank_iterate)
    }
    followers_joiner.run
  end

  #
  # Bin users by followers observed and get percentiles
  #
  task :trstquotient => [:join_pagerank_with_followers] do
    followers_binner.output << next_output(:trstquotient)
    followers_binner.input  << latest_output(:join_pagerank_with_followers)
    followers_binner.options = {
      :forank_table => "#{Settings.ics_tw_scripts}/projects/trstrank/forank_table.rb",
      :atrank_table => "#{Settings.ics_tw_scripts}/projects/trstrank/atrank_table.rb"
    }
    followers_binner.run
  end

  #
  # Assemble all the components to form final trstrank table
  #
  task :assemble_trstrank => [:trstquotient] do
    trstrank_assembler.pig_options = Settings.pig_opts
    trstrank_assembler.ouput << next_output(:assemble_trstrank)
    trstrank_assembler.options = {
      :tw_uid       => "#{Settings.input_dir}/twitter_user_id",
      :rank_with_tq => latest_output(:trstquotient),
      :out          => latest_output(:assemble_trstrank)
    }
    trstrank_assembler.run
  end
end

flow.workdir = '/tmp/pagerank'
flow.describe
flow.run :assemble_trstrank
