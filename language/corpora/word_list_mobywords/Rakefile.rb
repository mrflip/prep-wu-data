#!/usr/bin/env ruby
$:.unshift ENV['HOME']+'/ics/code/lib/ruby/lib' # find infinite monkeywrench lib
require 'imw.rb'
require 'yaml'
require 'rake'
require "ostruct"
require 'pathname'
require 'faster_csv'
require 'json'
require 'json/add/rails'
require 'json/add/core'

cat_subcat_coll = File.dirname(Pathname.new(__FILE__).realpath).split("/")[-3..-1]
dsm = DatasetMunger.new(*(cat_subcat_coll.map(&:to_sym)+[{}]))

dataset_files = 
  { 
  "letter_freq_mobywords_amy_tan"                  => "FICTION.TXT",   
  "word_list_mobywords_acronyms"                   => "ACRONYMS.TXT",  
  "word_list_mobywords_all_simple"                 => "SINGLE.TXT",    
  "word_list_mobywords_common"                     => "COMMON.TXT",    
  "word_list_mobywords_crossword"                  => "CROSSWD.TXT",   
  "word_list_mobywords_crossword_ospd2_delta"      => "CRSWD-D.TXT",   
  "word_list_mobywords_freq_bible"                 => "KJVFREQ.TXT",   
  "word_list_mobywords_freq_broad_corpus"          => "FREQ.TXT",      
  "word_list_mobywords_freq_internet"              => "FREQ-INT.TXT",  
  "word_list_mobywords_given_names_english"        => "NAMES.TXT",     
  "word_list_mobywords_given_names_english_female" => "NAMES-F.TXT",   
  "word_list_mobywords_given_names_english_male"   => "NAMES-M.TXT",   
  "word_list_mobywords_hyphenated"                 => "COMPOUND.TXT",  
  "word_list_mobywords_misspelled"                 => "OFTENMIS.TXT",  
  "word_list_mobywords_place_names"                => "PLACES.TXT",    
}
dataset_files_common = 
  ['word_list_mobywords_credits.txt', 
   'word_list_mobywords_README.txt'
  ]

formats = [:flat]

#
# Process files into raw packages
#
task :default => "imw:#{dsm.coll}:all"

namespace :imw do
  namespace dsm.coll do
    task :rip do
    end
    
    # Construct the rawd/ tree from the ripd/ tree
    task :rawd_build => :rip do
    end
    
    # Stuff the output into each fixd/ directory
    template_schema_file = dsm.path_to(:code_coll, dsm.coll.to_s+'_template.icss.yaml')
    datasets_schema_file = dsm.path_to(:code_coll, dsm.coll.to_s+'_datasets.icss.yaml')
    template_schema = YAML::load(File.open(template_schema_file))[0]['infochimps_schema']
    datasets_schema = YAML::load(File.open(datasets_schema_file))
    
    datasets_schema.each do |dataset_schema_h|
      dataset_schema = dataset_schema_h['infochimps_schema']
      dataset = dataset_schema['uniqid']
      formats.each do |format|
        fixd_dsf_dir        = dsm.path_to(:fixd_coll, "%s-%s" % [dataset, format])
        fixd_dsf_schemafile = dsm.path_to(fixd_dsf_dir, "%s.icss.yaml" % [dataset])        
        
        # Create file task
        file fixd_dsf_schemafile => [template_schema_file, datasets_schema_file] do
          # Create destination
          dsm.log('writing to', dataset, format, fixd_dsf_dir)
          mkdir_p dsm.path_to(fixd_dsf_dir)          
          # copy over common files (readme, etc)
          dataset_files_common.each do |file|
            cp file, fixd_dsf_dir
          end
          # put in payload
          cp dsm.path_to(:rawd_coll,dataset_files[dataset]), dsm.path_to(fixd_dsf_dir, dataset+'.flat.txt')          
          # add file info to schema 
          schema = template_schema.deep_merge(dataset_schema)
          schema['notes']["see_also"] = (dataset_files.keys - [dataset]).map{|sa| "* %s" % [sa]}.join("\n")
          schema['formats'] = {}; formats.each{|fmt| schema['formats'][fmt.to_s] = {}}   
          # dump schema
          schema = [{ 'infochimps_schema' => schema }]
          schemafile = dsm.path_to(fixd_dsf_dir, dataset+".icss.yaml")
          YAML::dump(schema, File.open(schemafile, "wb"))
          schemafile = dsm.path_to(:fixd_coll,   dataset+".icss.yaml")
          YAML::dump(schema, File.open(schemafile, "wb"))
        end # file task  
        task :rawd_process => fixd_dsf_schemafile
      end # format
    end
    
    task :all => [:rip, :rawd_build, :rawd_process] do
      true
    end
    
  end # collection  
end
