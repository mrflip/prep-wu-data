require 'rubygems'
require 'swineherd' ; include Swineherd

Settings.define :flow_id,      :required => true,                      :description => "ID with which to run the workflow."
Settings.define :mumakil_home, :default => '/usr/local/share/mumakil', :description => "Path to mumakil for Cassandra bulk interface"
Settings.define :host,         :default => '10.242.59.31',             :description => "Single ip of a cassandra seed"
Settings.define :ks,           :default => 'soc_net_tw',               :description => "Keyspace to dump from"
Settings.define :iterations,   :default => 10, :type => Integer,       :description => "Number of pagerank iterations to run"
Settings.define :pig_opts,     :env_var => 'PIG_OPTS'
Settings.resolve!
options = Settings.dup


here            = File.expand_path(File.dirname(__FILE__))
multigraph_dir  = File.expand_path(here+"/../../base/graph/multigraph")
pagerank_dir    = File.expand_path(here+"/../../base/graph/pagerank/dual_valued")
mumakil         = "#{options.mumakil_home}/bin/mumakil"

mumakil_options = {
    :generic         => "--longnames --host=#{options.host} --ks=#{options.ks}",
    :a_follows_b     => "--dumpcolumns --cf=AFollowsB",
    :a_atsigns_b     => "--dumpsupermap --cf=AAtsignsB",
    :twitter_user_id => "--dumptable --cf=TwitterUser --col_names=rsrc,user_id,scraped_at,screen_name,protected,followers_count,friends_count,statuses_count,favourites_count,created_at,sid,is_full,health",
    :output_dir      => "/tmp/dumped/#{options.flow_id}"
}

rearrange_options = {
  :a_follows_b => "#{multigraph_dir}/a_follows_b_from_cassandra.rb --run #{mumakil_options[:output_dir]}/a_follows_b",
  :a_atsigns_b => "#{multigraph_dir}/a_atsigns_b_from_cassandra.rb --run #{mumakil_options[:output_dir]}/a_atsigns_b",
  :output_dir  => "/tmp/rearranged/#{options.flow_id}"
}

multigraph_options = {
  :assembler  => "#{multigraph_dir}/assemble_multigraph.rb --run",
  :inputs     => "#{rearrange_options[:output_dir]}/a_follows_b,#{rearrange_options[:output_dir]}/a_atsigns_b",
  :output_dir => "/tmp/objects/#{options.flow_id}"
}

pagerank_options = {
  :initializer => "#{pagerank_dir}/dual_valued_initialize.pig",
  :runner      => "#{pagerank_dir}/dual_valued_pagerank.pig",
  :pig_opts    => options.pig_opts,
  :multigraph  => "#{multigraph_options[:output_dir]}/multi_edge",
  :output_dir  => "/tmp/pagerank/#{options.flow_id}"
}

def one_pagerank_iteration pagerank_options, curr_iter
  input  = File.join(pagerank_options[:output_dir], "pagerank_graph_#{curr_iter}")
  output = File.join(pagerank_options[:output_dir], "pagerank_graph_#{curr_iter+1}")
  system "PIG_OPTS=#{pagerank_options[:pig_opts]} pig -p CURR_ITER_FILE=#{input} -p NEXT_ITER_FILE=#{output} #{pagerank_options[:runner]}" unless Hfile.exist?(output)
end

# Tasks

task :dump_a_follows_b do
  output = File.join(mumakil_options[:output_dir], 'a_follows_b')
  system "#{mumakil} #{mumakil_options[:generic]} #{mumakil_options[:a_follows_b]} #{output}" unless Hfile.exist?(output)
end

task :dump_a_atsigns_b do
  output = File.join(mumakil_options[:output_dir], 'a_atsigns_b')
  system "#{mumakil} #{mumakil_options[:generic]} #{mumakil_options[:a_atsigns_b]} #{output}" unless Hfile.exist?(output)
end

task :dump_twitter_user_id do
  output = File.join(mumakil_options[:output_dir], 'twitter_user_id')
  system "#{mumakil} #{mumakil_options[:generic]} #{mumakil_options[:twitter_user_id]} #{output}" unless Hfile.exist?(output)
end

task :rearrange_a_follows_b => [:dump_a_follows_b] do
  output = File.join(rearrange_options[:output_dir], 'a_follows_b')
  system "#{rearrange_options[:a_follows_b]} #{output}" unless Hfile.exist?(output)
end

task :rearrange_a_atsigns_b => [:dump_a_atsigns_b] do
  output = File.join(rearrange_options[:output_dir], 'a_atsigns_b')
  system "#{rearrange_options[:a_atsigns_b]} #{output}" unless Hfile.exist?(output)
end

task :prepare_for_multigraph => [:rearrange_a_follows_b, :rearrange_a_atsigns_b]

task :assemble_multigraph => [:prepare_for_multigraph] do
  output = File.join(multigraph_options[:output_dir], 'multi_edge')
  system "#{multigraph_options[:assembler]} #{multigraph_options[:inputs]} #{output}" unless Hfile.exist?(output)
end

task :pagerank_initialize => [:assemble_multigraph] do
  output = File.join(pagerank_options[:output_dir], 'pagerank_graph_0')
  system "PIG_OPTS=#{options.pig_opts} pig -p MULTI=#{pagerank_options[:multigraph]} -p OUT=#{output} #{pagerank_options[:initializer]}" unless Hfile.exist?(output)
end

task :pagerank_iterate => [:pagerank_initialize] do
  options.iterations.times do |n|
    one_pagerank_iteration(pagerank_options, n)
  end
end

task :join_pagerank_with_followers => [:multigraph_degrees] do
  puts "Joining pagerank with followers, workflow = #{options.flow_id}"
end

task :multigraph_degrees => [:assemble_multigraph] do
  puts "Calculating multigraph degree distribution, workflow = #{options.flow_id}"
end

task :percentile_binning => [:join_pagerank_with_followers] do
  puts "Percentile binning, workflow = #{options.flow_id}"
end

task :assemble_trstrank => [:percentile_binning] do
  puts "Assembling final trstrank table, workflow = #{options.flow_id}"
end

