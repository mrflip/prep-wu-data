#!/usr/bin/env ruby

require 'swineherd' ; include Swineherd
require 'swineherd/script/pig_script' ; include Swineherd::Script
require 'swineherd/script/wukong_script'

Settings.read('./parse_config.yaml')
Settings.resolve!

def get_esindex month
  index = Settings['elasticsearch_indices_mapping'][month.to_i]
  return index if index
  "tweet-#{month}"
end

flow = Workflow.new(Settings['flow_id']) do
  
  api_parser          = WukongScript.new(File.join(Settings['wuclan_parse_scripts'], 'parse_twitter_api_requests-v2.rb'))
  stream_parser       = WukongScript.new(File.join(Settings['wuclan_parse_scripts'], 'parse_twitter_stream_requests-v2.rb'))
  search_parser       = WukongScript.new(File.join(Settings['wuclan_parse_scripts'], 'parse_twitter_search_request.rb'))
  unsplicer           = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'base/parse/unsplice_objects.pig.erb'))
  tweet_unsplicer     = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'base/parse/unsplice_tweets.pig.erb'))
  tweet_rectifier     = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'base/parse/rectify_objects/rectify_twnoids.pig.erb'))
  rels_rectifier      = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'base/parse/rectify_objects/rectify_ats_into_hbase.pig.erb'))
  token_indexer       = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'lib/elasticsearch/token_indexer.pig.erb'))
  tweet_indexer       = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'lib/elasticsearch/tweet_indexer.pig.erb'))
  a_ats_b_loader      = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'lib/hbase/templates/a_atsigns_b_loader.pig.erb'))
  a_fos_b_loader      = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'lib/hbase/templates/a_follows_b_loader.pig.erb'))
  delete_tweet_loader = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'lib/hbase/templates/delete_tweet_loader.pig.erb'))
  geo_loader          = PigScript.new(File.join(Settings['ics_data_twitter_scripts'], 'lib/hbase/templates/geo_loader.pig.erb'))
  
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

  #
  # Can't possibly work until we can talk to hbase with chimpark and other clusters
  #
  task :rectify_rels => [:unsplice] do
    expected_input = File.join(latest_output(:unsplice), "a_atsigns_b-n")
    next unless HDFS.exist? expected_input
    rels_rectifier.pig_classpath     = Settings['pig_classpath']
    rels_rectifier.options = {
      :ats_table   => Settings['hbase_relationships_table'],
      :twuid_table => Settings['hbase_twitter_users_table'],
      :ats         => expected_input
    }
    rels_rectifier.attributes = {:registers => Settings['hbase_registers']}
    rels_rectifier.output << next_output(:rectify_rels) # This has no hdfs output, actually
    rels_rectifier.run
    # HACK!
    sh "hadoop fs -mkdir #{latest_output(:rectify_rels)}" # so it doesn't run again
  end

  #
  # Rectify onto disk
  #
  task :rectify_twnoids => [:unsplice] do
    expected_input = File.join(latest_output(:unsplice), 'tweet-noid')
    next unless HDFS.exist? expected_input
    tweet_rectifier.pig_classpath = Settings['pig_classpath']
    tweet_rectifier.attributes = {
      :registers   => Settings['hbase_registers'],
      :twuid_table => Settings['hbase_twitter_users_table'],
      :data        => expected_input,
      :hdfs        => "hdfs://#{Settings['hdfs']}",
      :out         => next_output(:rectify_twnoids)
    }
    tweet_rectifier.output << latest_output(:rectify_twnoids)
    tweet_rectifier.run
  end

  task :unsplice_tweets => [:unsplice, :rectify_twnoids] do
    expected_tweet_input     = File.join(latest_output(:unsplice), 'tweet')
    expected_rectified_input = latest_output(:rectify_twnoids)
    if (HDFS.exist?(expected_tweet_input) || HDFS.exist?(expected_rectified_input)) 
      tweet_unsplicer.pig_classpath = Settings['pig_classpath']
      tweet_unsplicer.attributes    = {
        :piggybank_jar => File.join(Settings['pig_home'], 'contrib/piggybank/java/piggybank.jar'),
        :data          => [expected_tweet_input, expected_rectified_input].join(","),
        :hdfs          => "hdfs://#{Settings['hdfs']}",
        :out           => next_output(:unsplice_tweets)
      }
      tweet_unsplicer.output << latest_output(:unsplice_tweets)
      tweet_unsplicer.run
    end    
  end

  task :index_tweets => [:unsplice_tweets] do
    tweet_indexer.pig_classpath = Settings['pig_classpath']
    input_dir = latest_output(:unsplice_tweets)
    next unless HDFS.exist? input_dir
    HDFS.dir_entries(input_dir).each do |unspliced|
      next if unspliced =~ /_log/
      tweet_indexer.attributes = {
        :registers  => Settings['elasticsearch_registers'],
        :data       => unspliced,
        :index_name => get_esindex(File.basename(unspliced)),
        :obj_type   => 'tweet',
        :bulk_size  => 500
      }
      tweet_indexer.output << next_output(:index_tweets)
      tweet_indexer.run
      # HACK!
      sh "hadoop fs -mkdir #{latest_output(:index_tweets)}" # so it doesn't run again
      tweet_indexer.refresh!
    end
  end
  
  task :index_tokens => [:unsplice] do
    token_indexer.pig_classpath = Settings['pig_classpath']
    Settings['twitter_tokens'].each do |token|
      expected_input = File.join(latest_output(:unsplicer), token)
      next unless HDFS.exist? expected_input
      token_indexer.attributes = {
        :registers  => Settings['elasticsearch_registers'],
        :data       => expected_input,
        :index_name => 'token',
        :obj_type   => token,
        :bulk_size  => 500
      }
      token_indexer.output << next_output(:index_tokens)
      token_indexer.run
      # HACK!
      sh "hadoop fs -mkdir #{latest_output(:index_tokens)}" # so it doesn't run again
      token_indexer.refresh!
    end
  end

  
  task :load_a_atsigns_b => [:unsplice] do
    expected_input = File.join(latest_output(:unsplice), 'a_atsigns_b')
    next unless HDFS.exist? expected_input
    a_ats_b_loader.pig_classpath = Settings['pig_classpath']
    a_ats_b_loader.attributes = {
      :registers  => Settings['hbase_registers'],
      :data       => expected_input,
      :table      => Settings['hbase_relationships_table']
    }
    a_ats_b_loader.output << next_output(:load_a_atsigns_b)
    a_ats_b_loader.run

    # HACK!
    sh "hadoop fs -mkdir #{latest_output(:load_a_atsigns_b)}" # so it doesn't run again    
  end

  task :load_a_follows_b => [:unsplice] do
    expected_input = File.join(latest_output(:unsplice), 'a_follows_b')
    next unless HDFS.exist? expected_input
    a_fos_b_loader.pig_classpath = Settings['pig_classpath']
    a_fos_b_loader.attributes = {
      :registers  => Settings['hbase_registers'],
      :data       => expected_input,
      :table      => Settings['hbase_relationships_table']
    }
    a_fos_b_loader.output << next_output(:load_a_follows_b)
    a_fos_b_loader.run

    # HACK!
    sh "hadoop fs -mkdir #{latest_output(:load_a_follows_b)}" # so it doesn't run again    
  end

  task :load_delete_tweets => [:unsplice] do
    expected_input = File.join(latest_output(:unsplice), 'delete_tweet')
    next unless HDFS.exist? expected_input
    delete_tweet_loader.pig_classpath = Settings['pig_classpath']
    delete_tweet_loader.attributes = {
      :registers  => Settings['hbase_registers'],
      :data       => expected_input,
      :table      => Settings['hbase_delete_tweet_table']
    }
    delete_tweet_loader.output << next_output(:load_delete_tweets)
    delete_tweet_loader.run

    # HACK!
    sh "hadoop fs -mkdir #{latest_output(:load_delete_tweets)}"
  end

  task :load_geo => [:unsplice] do
    expected_input = File.join(latest_output(:unsplice), 'geo')
    next unless HDFS.exist? expected_input
    geo_loader.pig_classpath = Settings['pig_classpath']
    geo_loader.attributes = {
      :registers  => Settings['hbase_registers'],
      :data       => expected_input,
      :table      => Settings['hbase_geo_table']
    }
    geo_loader.output << next_output(:load_geo)
    geo_loader.run

    # HACK!
    sh "hadoop fs -mkdir #{latest_output(:load_geo)}"
  end  
   
end

flow.workdir = Settings['hdfs_work_dir']
flow.describe
flow.run(Settings.rest.first)
# flow.clean!
