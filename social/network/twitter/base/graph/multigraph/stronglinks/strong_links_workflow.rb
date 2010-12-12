#!/usr/bin/env ruby

require 'swineherd'                      ; include Swineherd
require 'swineherd/script/pig_script'    ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.define :flow_id,      :required => true, :description => "Workflow id required to make individual runs idempotent"
Settings.define :input_dir,    :required => true, :description => "Path to look for required workflow inputs"
Settings.define :reduce_tasks, :default  => 60,   :description => "Change to reduce task capacity on cluster"
Settings.define :scripts,      :default  => "/home/jacob/Programming/infochimps-data/social/network/twitter/base/graph/multigraph/stronglinks"
Settings.resolve!

flow = Workflow.new(Settings.flow_id) do

  weighted_edges = WukongScript.new("#{Settings.scripts}/weighted_edge.rb")
  assembler      = PigScript.new("#{Settings.scripts}/assemble_strong_links.pig")

  task :weighted_edges do
    weighted_edges.options = {:multiedge_definition => "#{Settings.scripts}/multiedge.rb"}
    weighted_edges.input  << "#{Settings.input_dir}/multi_edge"
    weighted_edges.output << next_output(:weighted_edges)
    weighted_edges.run
  end

  task :assemble_strong_links => [:weighted_edges] do
    assembler.output      << next_output(:assemble_strong_links)
    assembler.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    assembler.options     = {
      :wedges  => latest_output(:weighted_edges),
      :twuid   => "#{Settings.input_dir}/twitter_user_id",
      :strlnks => latest_output(:assemble_strong_links)
    }
    assembler.run
  end

end

flow.workdir = "/tmp/strong_links"
flow.describe
flow.run(Settings.rest.first)
# flow.clean!
