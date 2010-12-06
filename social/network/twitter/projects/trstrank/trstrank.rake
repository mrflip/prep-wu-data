require 'rubygems'
require 'swineherd' ; include Swineherd

Settings.define :iterations,     :default => 10, :type => Integer, :description => "Number of pagerank iterations to run"
Settings.define :ics_tw_scripts, :default => "/home/jacob/Programming/infochimps-data/social/network/twitter"
Settings.define :pig_opts,       :env_var => 'PIG_OPTS'
Settings.resolve!

def one_pagerank_iteration n
  script         = PigScript.new("#{Settings.ics_tw_scripts}/base/graph/pagerank/dual_valued/dual_valued_pagerank.pig")
  script.options = {
    :curr_iter_file => "/tmp/pagerank/pagerank_iteration_#{n}",
    :next_iter_file => "/tmp/pagerank/pagerank_iteration_#{n+1}",
    :damp           => "0.85f"
  }
  script.pig_options = Settings.pig_opts
  script.output  << script.options[:next_iter_file]
  script.run
end

task :assemble_multigraph do
  script = WukongScript.new("#{Settings.ics_tw_scripts}/base/graph/multigraph/assemble_multigraph.rb")
  script.input  << "/tmp/objects/a_follows_b"
  script.input  << "/tmp/objects/a_atsigns_b"
  script.output << "/tmp/objects/multi_edge"
  script.run
end

task :pagerank_initialize => [:assemble_multigraph] do
  script = PigScript.new("#{Settings.ics_tw_scripts}/base/graph/pagerank/dual_valued/dual_valued_initialize.pig")
  script.options     = {:multi => "/tmp/objects/multi_edge", :out => "/tmp/pagerank/pagerank_iteration_0"}
  script.pig_options = Settings.pig_opts
  script.output      << script.options[:out]
  script.run
end

task :pagerank_iterate => [:pagerank_initialize] do
  Settings.iterations.times do |n|
    one_pagerank_iteration n
  end
end

multitask :join_pagerank_with_followers => [:multigraph_degrees, :pagerank_iterate] do
  script = PigScript.new("#{Settings.ics_tw_scripts}/projects/trstrank/join_pr_with_followers.pig")
  script.options = {:dist => "/tmp/objects/degree_distribution", :out => "/tmp/trstrank/scaled_pagerank_with_fo", :prgraph => "/tmp/pagerank/pagerank_iteration_#{Settings.iterations}"}
  script.output << script.options[:out]
  script.run
end

task :multigraph_degrees => [:assemble_multigraph] do
  script = PigScript.new("#{Settings.ics_tw_scripts}/base/graph/multigraph/multigraph_degrees.pig")
  script.options = {:degree => "/tmp/objects/degree_distribution", :graph => "/tmp/objects/multi_edge"}
  script.output << "/tmp/objects/degree_distribution"
  script.run
end

task :trstquotient => [:join_pagerank_with_followers] do
  script = WukongScript.new("#{Settings.ics_tw_scripts}/projects/trstrank/trst_quotient.rb")
  script.options = {
    :forank_table => "#{Settings.ics_tw_scripts}/projects/trstrank/forank_table.rb",
    :atrank_table => "#{Settings.ics_tw_scripts}/projects/trstrank/atrank_table.rb"
  }
  script.input  << "/tmp/trstrank/scaled_pagerank_with_fo"
  script.output << "/tmp/trstrank/scaled_pagerank_with_tq"
  script.run
end

task :assemble_trstrank => [:trstquotient] do
  script = PigScript.new("#{Settings.ics_tw_scripts}/projects/trstrank/trstrank_assembler.pig")
  script.options = {
    :tw_uid       => "/tmp/objects/twitter_user_id",
    :rank_with_tq => "/tmp/trstrank/scaled_pagerank_with_tq",
    :out          => "/tmp/trstrank/trstrank_table"
  }
  script.run
end
