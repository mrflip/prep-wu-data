#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'
require 'rake'
require "ostruct"



dsm = DatasetMunger.new(:culture, :music, :musicbrainz, {})

# source URLs: ripped, and form the path in the data/ripd/ hierarchy
dsm.rips    = 
  [
   'ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/' 
  ]

# source_packages
dsm.source_packages = dsm.rips.map do |rip| 
  FileList[dsm.path_to(:ripd_root, rip, "*/*.tar.bz2")].to_a
end.sum()

# dsm.source_packages = 
#   %w{
#    mbdump-artistrelation.tar.bz2    
#    mbdump-derived.tar.bz2     
#    mbdump-stats.tar.bz2  
#    mbdump-closedmoderation.tar.bz2  
#    mbdump-moderation.tar.bz2  
#   }.map{ |f| dsm.path_to(:ripd_root, f) }

#
# Process files into raw packages
#
task :default => "imw:#{dsm.coll}:all"

namespace :imw do

  namespace dsm.coll do

    dsm.rips.each do |rip|
      ripd_rip_dir = dsm.path_to([:ripd_root, rip])
      task :ripd => [ripd_rip_dir]
    end
    
    task :rip do
    end
    
    # Construct the rawd/ tree from the ripd/ tree
    task :rawd_build => :rip do
      dsm.log('running task', :rawd_build)
      cd dsm.path_to(:rawd_coll)
      puts dsm.to_yaml
      
      directory dsm.path_to(:rawd_coll)
      dsm.source_packages.each do |pkg|
        # dsm.unpackage(pkg, dsm.path_to(:rawd_coll))
      end
      
    end
    
    # file dsm.path_to(:code_schema_datasets)
    # => [dsm.path_to(:code_schema_datasets), dsm.path_to(:code_schema_datasets)] 
    task :rawd_process do
      dsm.log('running task', :ripd_process)
      schema_datasets = YAML::load(dsm.path_to(:code_schema_datasets))   
      schema_template = YAML::load(dsm.path_to(:code_schema_template))   
      #
      schema_datasets.each do |ds_sch|
        puts ds_sch.to_json
        schema_dataset = ds_sch['infochimps_schema_segment'] or next
        schema = schema_template.deep_merge(schema_dataset)
        dsm.fix_uniqid!(schema)
        schema_out_filename = dsm.path_to(:fixd_coll, schema['uniqid']+'.icss.yaml')
        dsm.log schema_out_filename
        File.open() do |f|
          YAML::dump(schema, f)
        end
      end
    end
    
    task :all => [:rip, :rawd_build, :rawd_process] do
      true
    end
    
  end
end




# Copy the FAQ and the README over


# Copy the package file over


# Stuff in the schema info, copy that over


