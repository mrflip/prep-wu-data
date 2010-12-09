#!/usr/bin/env ruby

require 'swineherd'                      ; include Swineherd
require 'swineherd/script/pig_script'    ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.define :flow_id,                 :required => true, :description => "Workflow needs a unique numeric id"
Settings.define :data_input_dir,          :required => true, :description => "Path to necessary twitter data"
Settings.define :reduce_tasks,            :default  => 96,   :description => "Change to reduce task capacity on cluster"
Settings.define :stronglinks_scripts,     :default  => "/home/travis/infochimps-data/social/network/twitter/base/graph/multigraph/stronglinks"
Setting.resolve!

flow = Workflow.new(Settings.flow_id) do

  weighted_edges        = WukongScript.new("#{Settings.stronglinks_scripts}/weighted_edge.rb")
  assemble_strong_links = PigScript.new("#{Settings.stronglinks_scripts}/assemble_strong_links.pig")

  task :weighted_edges do
    weighted_edges.input  << "#{Settings.data_input_dir}/multi_edge"
    weighted_edges.output << next_output(:weighted_edges)
    weighted_edges.run
  end

  task :assemble_strong_links => [:weighted_edges] do
    assemble_strong_links.output      << next_output(:assemble_strong_links)
    assemble_strong_links.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    assemble_strong_links.options     = {
      :wedges  => latest_output(:weighted_edges)
      :twuid   => "#{Settings.data_input_dir}/twitter_user_id"
      :strlnks => latest_output(:assemble_strong_links)
    }
    assemble_strong_links.run
  end

end

flow.workdir = "/tmp/strong_links"
flow.describe
flow.run(Settings.rest.first)
# flow.clean!
