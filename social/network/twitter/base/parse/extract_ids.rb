#!/usr/bin/env ruby

objects_dir = ARGV[0]
output_dir  = ARGV[1]
inputs = []

%w[ twitter_user_partial twitter_user tweet a_follows_b ].each do |object|
  hdfs_path = File.join(objects_dir, object) 
  next unless system %Q{hadoop fs -test -e #{hdfs_path}}
  inputs << hdfs_path
end

system %Q{#{File.dirname(__FILE__)}/twitter_user_ids_from_objects.rb --rm --run #{inputs.join(",")} #{output_dir}; true } unless inputs.empty?
