#!/usr/bin/env ruby

require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.read('./parse_config.yaml')
Settings.resolve!

flow = Workflow.new(Settings['flow_id']) do
  
  api_parser    = WukongScript.new(File.join(Settings['wuclan_parse_scripts'], 'parse_twitter_api_requests-v2.rb'))
  stream_parser = WukongScript.new(File.join(Settings['wuclan_parse_scripts'], 'parse_twitter_stream_requests-v2.rb'))
  search_parser = WukongScript.new(File.join(Settings['wuclan_parse_scripts'], 'parse_twitter_search_request.rb'))
  unsplicer     = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'base/parse/unsplice_objects.pig.erb'))
  
  task :parse_twitter_api do
    api_parser.input << File.join(Settings['ripd_s3_url'], 'com.twitter', Settings['api_parse_regexp'])
    api_parser.output << next_output(:parse_twitter_api)
    api_parser.run
  end

  task :parse_twitter_search do
    search_parser.input << File.join(Settings['ripd_s3_url'], 'com.twitter.search', Settings['search_parse_regexp'])
    search_parser.output << next_output(:parse_twitter_search)
    search_parser.run
  end

  task :parse_twitter_stream do
    stream_parser.input << File.join(Settings['ripd_s3_url'], 'com.twitter.stream', Settings['stream_parse_regexp'])
    stream_parser.output << next_output(:parse_twitter_stream)
    stream_parser.run
  end

  task :parse_all => ["#{Settings['flow_id']}:parse_twitter_api", "#{Settings['flow_id']}:parse_twitter_search", "#{Settings['flow_id']}:parse_twitter_stream"] do
  end

  task :unsplice => [:parse_all] do
    unsplicer.attributes = {:piggybank_jar => File.join(Settings['pig_home'], 'contrib/piggybank/java/piggybank.jar')}
    unsplicer.options    = {
      :api    => latest_output(:parse_twitter_api),
      :search => latest_output(:parse_twitter_search),
      :stream => latest_output(:parse_twitter_stream),
      :out    => next_output(:unsplice)
    }
    unsplicer.output << latest_output(:unsplice)
    unsplicer.run
  end

end

flow.workdir = Settings['hdfs_work_dir']
flow.describe
flow.run(Settings.rest.first)
# flow.clean!
