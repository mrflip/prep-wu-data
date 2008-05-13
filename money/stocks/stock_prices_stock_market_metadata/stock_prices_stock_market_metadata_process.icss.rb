#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'
require 'rake'
require "ostruct"
require 'pathname'


cat_subcat_coll = File.dirname(Pathname.new(__FILE__).realpath).split("/")[-3..-1]
dsm = DatasetMunger.new(*(cat_subcat_coll.map(&:to_sym)+[{}]))
puts dsm.to_yaml

# source URLs: ripped, and form the path in the data/ripd/ hierarchy
dsm.rips    = 
  [
   'http://www.nasdaq.com/asp/symbols.asp?exchange=Q&start=0', 
   'http://www.nasdaq.com/asp/symbols.asp?exchange=1&start=0', 
   'http://www.nasdaq.com/asp/symbols.asp?exchange=N&start=0',
  ]

# ripd_files
dsm.ripd_files  = dsm.rips.map do |rip| 
  FileList[dsm.path_to(:ripd_root, rip, "*exchange")].to_a
end.sum()

# pattern, dest for building the data/rawd hier.
dsm.rawd_moves = 
  [
   { :from => /www.nasdaq.com\/asp\/.*exchange=Q/, :to => 'Symbol-Name-NASDAQ-all.csv' },
   { :from => /www.nasdaq.com\/asp\/.*exchange=1/, :to => 'Symbol-Name-AMEX-all.csv'   },
   { :from => /www.nasdaq.com\/asp\/.*exchange=N/, :to => 'Symbol-Name-NYSE-all.csv'   },
  ]

# dsm.ripd_files = 
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
      dsm.log('running task', :ripd_unpackage)
      directory dsm.path_to(:rawd_coll)
      dsm.ripd_files.each do |rawd_file|
        dsm.rawd_moves.each do |patt, dest|
          if rawd_file.match(patt)
            cp rawd_file, dsm.path_to(:rawd_coll, dest)
          end
        end
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
    
    task :all => [:rip, :ripd_unpackage, :rawd_process] do
      true
    end
    
  end
end




# Copy the FAQ and the README over


# Copy the package file over


# Stuff in the schema info, copy that over


