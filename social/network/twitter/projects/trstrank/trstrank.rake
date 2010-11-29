require 'rubygems'
require 'swineherd'

Settings.define :flow_id,      :required => true,                      :description => "ID with which to run the workflow."
Settings.define :mumakil_home, :default => '/usr/local/share/mumakil', :description => "Path to mumakil for Cassandra bulk interface"
Settings.define :host,         :default => '10.242.59.31',             :description => "Single ip of a cassandra seed"
Settings.define :ks,           :default => 'soc_net_tw',               :description => "Keyspace to dump from"

Settings.resolve!

options = Settings.dup

here = File.expand_path(File.dirname(__FILE__))

task :dump_from_cassandra do
  types               = %w[a_atsigns_b a_follows_b twitter_user_id]
  puts "Dumping #{types.join(", ")} from cassandra ..."
  mumakil             = ["#{options.mumakil_home}/bin/mumakil"]
  mumakil_options     = {
    :generic         => ["--longnames", "--host=#{options.host}", "--ks=#{options.ks}"],
    :a_follows_b     => ["--dumpcolumns", "--cf=AFollowsB", "/tmp/dumped/#{options.flow_id}/a_follows_b_list"],
    :a_atsigns_b     => ["--dumpsupermap", "--cf=AAtsignsB", "/tmp/dumped/#{options.flow_id}/a_atsigns_b_list"],
    :twitter_user_id => ["--dumptable", "--cf=TwitterUser", "--col_names=rsrc,user_id,scraped_at,screen_name,protected,followers_count,friends_count,statuses_count,favourites_count,created_at,sid,is_full,health", "/tmp/dumped/#{options.flow_id}/twitter_user_id"]
  }
  types.each do |type|
    system(*[mumakil, mumakil_options[:generic], mumakil_options[type.to_sym], '&'].flatten)
  end
end

task :prepare_for_multigraph => [:dump_from_cassandra] do
  puts "Preparing dumped data for multigraph, workflow = #{options.flow_id}"
end

task :assemble_multigraph => [:prepare_for_multigraph] do
  puts "Assembling multigraph, workflow = #{options.flow_id}"
end

task :pagerank_initialize => [:assemble_multigraph] do
  puts "Initializing pagerank, workflow = #{options.flow_id}"
end

task :pagerank_iterate => [:pagerank_initialize] do
  puts "Iterating pagerank, workflow = #{options.flow_id}"
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

