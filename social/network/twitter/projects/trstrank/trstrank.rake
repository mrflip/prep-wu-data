require 'rubygems'
require 'swineherd'

task :dump_from_cassandra do
  puts "Dumping from cassandra"
end

task :prepare_for_multigraph => [:dump_from_cassandra] do
  puts "Preparing dumped data for multigraph"
end

task :assemble_multigraph => [:prepare_for_multigraph] do
  puts "Assembling multigraph"
end

task :pagerank_initialize => [:assemble_multigraph] do
  puts "Initializing pagerank"
end

task :pagerank_iterate => [:pagerank_initialize] do
  puts "Iterating pagerank"
end

task :join_pagerank_with_followers => [:multigraph_degrees] do
  puts "Joining pagerank with followers"
end

task :multigraph_degrees => [:assemble_multigraph] do
  puts "Calculating multigraph degree distribution"
end

task :percentile_binning => [:join_pagerank_with_followers] do
  puts "Percentile binning"
end

task :assemble_trstrank => [:percentile_binning] do
  puts "Assembling final trstrank table"
end

