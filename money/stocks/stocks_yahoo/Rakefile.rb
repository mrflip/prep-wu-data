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

exchanges = ['NYSE', 'AMEX', 'NASDAQ']
formats = [:csv, :yaml]

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
    
    # file dsm.path_to(:code_schema_datasets)
    # => [dsm.path_to(:code_schema_datasets), dsm.path_to(:code_schema_datasets)] 

    exchanges.each do |exchg|
      fixd_csv_out = dsm.path_to(:fixd_coll, exchg+'-all.csv')
      file fixd_csv_out => [:rawd_build] do
        # process_yahoo_stock_history()
      end # file task
      task :rawd_process => fixd_csv_out    
    end
    
    exchanges.each do |exchg|
      formats.each do |format|
        schemafile = dsm.path_to(:fixd_coll, "%s_%s-%s" % [dsm.coll, exchg, format], "%s_%s.icss.yaml" % [dsm.coll, exchg])
        file schemafile  do
          exchanges.each do |exchg|
            dsm.log('writing to', exchg)
            formats.each do |format|
              schemafile_in = dsm.path_to(:code_coll, "%s_%s.icss.yaml" % [dsm.coll, 'template'])
              schema = YAML::load(File.open(schemafile_in))[0]['infochimps_schema']
              schema['name']   = schema['name'] + " (#{exchg} exchange)"
              schema['uniqid'] = "%s_%s" % [dsm.coll, exchg]
              schema['notes']["see_also"] = exchanges.map{ |exchg_sa| "%s_%s" % [dsm.coll, exchg_sa]}.to_yaml
              sch_formats = {}; formats.each{|fmt| sch_formats[fmt.to_s] = {}}
              schema['formats'] = sch_formats
              mkdir_p dsm.path_to(:fixd_coll)
              
              schema = [{ 'infochimps_schema' => schema }]
              schemafile = dsm.path_to(:fixd_coll, "%s_%s-%s" % [dsm.coll, exchg, format], "%s_%s.icss.yaml" % [dsm.coll, exchg])
              YAML::dump(schema, File.open(schemafile, "wb"))
              schemafile = dsm.path_to(:fixd_coll, "%s_%s.icss.yaml" % [dsm.coll, exchg])
              dsm.log('writing to', schemafile)
              YAML::dump(schema, File.open(schemafile, "wb"))
            end 
          end
        end # file task  
        task :rawd_process => schemafile
      end
      
    end
    
    
    task :all => [:rip, :rawd_build, :rawd_process] do
      true
    end
    
  end
end



def process_yahoo_stock_history()
  dsm.log('running task', :ripd_process, fixd_csv_out)      
  # order of fields
  fields_for = {
    'daily_prices'  => ["exchange", "stock_symbol", "date", "stock_price_open", "stock_price_high", "stock_price_low", "stock_price_close", "stock_volume", "stock_price_adj_close"],
    'dividends'     => ["exchange", "stock_symbol", "date", "dividends"],
  }
  # Chunk by letter
  letters = ('A'..'Z').to_a + ('0'..'9').to_a
  
  letters.each do |initial_letter|
    exchanges.each do |exchg|          
      # for each stock, and for both splits/dividends and prices,
      stock_history      = {}
      stock_history_flat = { 'dividends' => [], 'daily_prices' => [] }
      FileList[dsm.path_to(:rawd_coll, exchg+'-'+initial_letter+'/Symbol-*.csv')].each do |stockfile|
        dsm.log('Processing', stockfile, 
                '(%7d dividends, %7d prices so far)' % [stock_history_flat['dividends'].length, stock_history_flat['daily_prices'].length])
        # record exchg -> stock -> divs / splits -> all records
        stock_measure, junk, stock_symbol = stockfile.to_s.match(/Symbol-(Div|Stk)-(\w+)-(\w+)\.csv/)[1..3]            
        stock_measure = { 'Div' => 'dividends', 'Stk' => 'daily_prices' }[stock_measure]
        stock_history[stock_symbol] ||= {}
        stock_history[stock_symbol][stock_measure] = []
        first = true
        FasterCSV.foreach(stockfile) do |row|
          if first then first = false ; next ; end
          # ["NYSE", "QXM", "Div", "Date", "Dividends"]
          # ["NYSE", "QI", "Stk", "Date", "Open", "High", "Low", "Close", "Volume", "Adj Close"]
          flat_vals = [exchg, stock_symbol] + row.map(&:to_s)
          vals = Hash.zip(fields_for[stock_measure], flat_vals)
          if (stock_measure == 'daily_prices') then 
            ["open", "high", "low", "close", "adj close"].each do |f| 
              vals[f] = vals[f].to_f
            end
            vals["volume"] = vals["volume"].to_i
          else
            vals["dividends"] = vals["dividends"].to_f
          end
          stock_history[stock_symbol][stock_measure].push(vals)
          stock_history_flat[stock_measure].push(fields_for[stock_measure].map{|f| vals[f]})
        end # csv file            
      end # divs, prices
      
      dump_yaml(dsm, stock_history)
      dump_csv( dsm, fields_for_history_flat, stock_history_flat)
      
    end # exchg
    dsm.log("Done with", exchg, initial_letter)
  end # letter
end


def dump_yaml(dsm, stock_history)
  # Dump as YAML
  fixd_yaml_dir  = dsm.path_to(:fixd_coll,    "%s_%s-%s"   % [dsm.coll, exchg, 'yaml'])
  fixd_yaml_file = dsm.path_to(fixd_yaml_dir, "%s_%s_%s.yaml" % [dsm.coll, exchg, initial_letter])
  dsm.log("Writing out to ", fixd_yaml_dir)  
  mkdir_p fixd_yaml_dir
  File.open(fixd_yaml_file, 'w') do |file|
    file << JSON.generate({exchg => stock_history}, 
                          {:indent =>"  ", :space => " ", :object_nl => "", :array_nl => "\n",
                            :check_circular => false, :allow_nan => true, :max_nesting => false})
  end
  
end

def dump_csv(dsm, fields_for_history_flat, stock_history_flat)
  # Dump as CSV
  fixd_csv_dir  = dsm.path_to(:fixd_coll,    "%s_%s-%s"  % [dsm.coll, exchg, 'csv'])
  mkdir_p fixd_csv_dir
  # dump divs, then dump prices
  fields_for.keys.each do |stock_measure|
    fixd_csv_file = dsm.path_to(fixd_csv_dir, "%s_%s_%s_%s.csv" % [dsm.coll, exchg, stock_measure, initial_letter]) 
    dsm.log("Writing out to ", fixd_csv_dir)           
    FasterCSV.open(fixd_csv_file, 'wb') do |csv|
      csv << fields_for[stock_measure]
      stock_history_flat[stock_measure]. each do |row|
        csv << row
      end
    end
  end # divs, prices
end



# Copy the FAQ and the README over


# Copy the package file over


# Stuff in the schema info, copy that over


      # schema_datasets = YAML::load(dsm.path_to(:code_schema_datasets))   
      # schema_template = YAML::load(dsm.path_to(:code_schema_template))   
      # #
      # schema_datasets.each do |ds_sch|
      #   puts ds_sch.to_json
      #   schema_dataset = ds_sch['infochimps_schema_segment'] or next
      #   schema = schema_template.deep_merge(schema_dataset)
      #   dsm.fix_uniqid!(schema)
      #   schema_out_filename = dsm.path_to(:fixd_coll, schema['uniqid']+'.icss.yaml')
      #   dsm.log schema_out_filename
      #   File.open() do |f|
      #     YAML::dump(schema, f)
      #   end
      # end
