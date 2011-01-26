#!/usr/bin/env ruby

require 'rubygems'
require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.define :flow_id,    :required => true, :description => "Flow id required to make run of workflow unique"
Settings.define :input_dir,  :required => true, :description => "HDFS directory where input data lives"
Settings.define :ics_tw_scripts, :default => "/home/jacob/Programming/infochimps-data/social/network/twitter"
Settings.define :pig_opts,       :env_var => 'PIG_OPTS'
Settings.resolve!

#
# twitter_user, a_atsigns_b, a_follows_b, tweet
#
flow = Workflow.new(Settings.flow_id) do

  #
  # Scripts needed to run id workflow
  #
  object_id_extractor = WukongScript.new("#{Settings.ics_tw_scripts}/base/parse/twitter_ids/twitter_user_ids_from_objects.rb")
  rel_id_extractor    = PigScript.new("#{Settings.ics_tw_scripts}/base/parse/twitter_ids/extract_ids_from_rel.pig")
  uid_sn_extractor    = PigScript.new("#{Settings.ics_tw_scripts}/base/parse/twitter_ids/extract_uid_sn_mapping.pig")
  ids_assembler       = PigScript.new("#{Settings.ics_tw_scripts}/base/parse/twitter_ids/assemble_id_mapping.pig")
  
  #
  # Take a_follows_b and a_atsigns_b and assemble multigraph
  #
  task :ids_from_objects do
    object_id_extractor.output << next_output(:ids_from_objects)
    object_id_extractor.input  << "#{Settings.input_dir}/twitter_user_id"      if HDFS.exist?("#{Settings.input_dir}/twitter_user_id")
    object_id_extractor.input  << "#{Settings.input_dir}/twitter_user"         if HDFS.exist?("#{Settings.input_dir}/twitter_user")
    object_id_extractor.input  << "#{Settings.input_dir}/twitter_user_partial" if HDFS.exist?("#{Settings.input_dir}/twitter_user_partial")
    object_id_extractor.input  << "#{Settings.input_dir}/a_follows_b"          if HDFS.exist?("#{Settings.input_dir}/a_follows_b")
    object_id_extractor.input  << "#{Settings.input_dir}/tweet"                if HDFS.exist?("#{Settings.input_dir}/tweet")
    object_id_extractor.run
  end

  #
  # It's redundant, scripts are in serious need of refactoring
  #
  task :ids_from_rels do
    rel_id_extractor.output << next_output(:ids_from_rels)
    rel_id_extractor.pig_options = Settings.pig_opts
    rel_id_extractor.options     = {:afb => "#{Settings.input_dir}/a_follows_b", :out => latest_output(:ids_from_rels)}
    rel_id_extractor.run
  end

  #
  # It's redundant, scripts are in serious need of refactoring
  #
  task :uid_sn_mapping do
    uid_sn_extractor.output << next_output(:uid_sn_mapping)
    uid_sn_extractor.pig_options = Settings.pig_opts
    uid_sn_extractor.options = {:tweet => "#{Settings.input_dir}/tweet", :out => latest_output(:uid_sn_mapping)}
    uid_sn_extractor.run
  end

  #
  # FIXME: search ids path is hardcoded for now, fix once we have new search id objects
  #
  task :assemble_twitter_user_id => [:ids_from_objects, :ids_from_rels, :uid_sn_mapping] do
    ids_assembler.output << next_output(:assemble_twitter_user_id)
    ids_assembler.pig_options = Settings.pig_opts
    ids_assembler.options = {
      :tw_uid  => latest_output(:ids_from_objects),
      :tw_sid  => "s3://s3hdfs.infinitemonkeys.info/data/sn/tw/fixd/20100806/twitter_user_search_id",
      :id_sn   => latest_output(:uid_sn_mapping),
      :rel_ids => latest_output(:ids_from_rels),
      :out     => latest_output(:assemble_twitter_user_id)
    }
    ids_assembler.run
  end

end

flow.workdir = '/tmp/twitter_ids'
flow.describe
flow.run :assemble_twitter_user_id
