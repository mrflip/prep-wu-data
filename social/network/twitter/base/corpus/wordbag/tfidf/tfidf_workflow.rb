#!/usr/bin/env ruby

require 'swineherd'                   ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script' ; include Swineherd::Script

Settings.define :flow_id,      :required => true, :description => "Workflow needs a unique numeric id"
Settings.define :input_dir,    :required => true, :description => "Path to necessary data"
Settings.define :n_users,                         :description => "Number of users who've used tokens, see warning"
Settings.define :reduce_tasks, :default  => 96,   :description => "Change to reduce task capacity on cluster"
Settings.define :script_path,  :default  => "/home/jacob/Programming/infochimps-data/social/network/twitter/base/corpus"
Settings.define :n_toks,       :default  => "100", :description => "Number of tokens to include in wordbag"
Settings.resolve!

#
# WARNING: You cannot run this workflow from end-to-end at the moment. You
# should run up to and including 'user_frequencies'. Then, fetch the number of
# users by looking at the 'combine input groups' on the jobtracker for
# document_frequencies.pig. Next, run the workflow the same, this time passing
# in the number of users as an option.
#
flow = Workflow.new(Settings.flow_id) do
  tokenizer   = WukongScript.new("#{Settings.script_path}/tokenize/extract_word_tokens.rb")
  frequencies = PigScript.new("#{Settings.script_path}/wordbag/tfidf/document_frequencies.pig")
  tfidf       = PigScript.new("#{Settings.script_path}/wordbag/tfidf/tfidf.pig")
  top_n_bag   = PigScript.new("#{Settings.script_path}/wordbag/tfidf/top_n_bag.pig")

  task :tokenize do
    tokenizer.input  << "#{Settings.input_dir}/tweet"
    tokenizer.output << next_output(:tokenize)
    tokenizer.run
  end

  task :user_frequencies => [:tokenize] do
    frequencies.output << next_output(:user_frequencies)
    frequencies.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    frequencies.options     = {
      :usages      => latest_output(:tokenize),
      :usage_freqs => latest_output(:user_frequencies)
    }
    frequencies.run
  end

  task :tfidf_weights => [:user_frequencies] do
    tfidf.output << next_output(:tfidf_weights)
    tfidf.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    tfidf.options     = {
      :usage_freqs      => latest_output(:user_frequencies),
      :n_users          => "#{Settings.n_users}l",
      :user_token_graph => latest_output(:tfidf_weights)
    }
    tfidf.run
  end

  task :top_n_bag => [:tfidf_weights] do
    top_n_bag.output << next_output(:top_n_bag)
    top_n_bag.pig_options = "-Dmapred.reduce.tasks=#{Settings.reduce_tasks}"
    top_n_bag.options     = {
      :n       => Settings.n_tokens,
      :twuid   => "#{Settings.input_dir}/twitter_user_id",
      :bigrph  => latest_output(:tfidf_weights),
      :wordbag => latest_output(:top_n_bag)
    }
    top_n_bag.run
  end

end

flow.workdir = "/tmp/wordbag"
flow.describe
flow.run(Settings.rest.first)
