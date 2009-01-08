#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/../lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/scraped_file'
require 'twitter_friends/scrape_store'
# require 'twitter_friends/json_model'

class InsertIdsMapper <  Hadoop::Streamer
  def process resource, *vals
    case
    when resource == 'twitter_user_id'
      id, screen_name = vals
      screen_name ||= "!bogus-#{id}"
      puts [screen_name.downcase, resource, *vals].join("\t")
    else 
      puts [resource, *vals].join("\t")
    end
  end
end

class InsertIdsReducer < Hadoop::AccumulatingStreamer
  attr_accessor :screen_name, :twitter_user_id, :scraped_contents
  def reset!
    super
    self.twitter_user_id = nil
    self.scraped_contents   = []
  end

  #
  # gather, for each screen name, the ID and all files' contents
  #
  def accumulate key, resource, *vals
    self.screen_name = key
    case
    when resource == 'twitter_user_id'
      self.twitter_user_id = vals[0]
    else 
      self.scraped_contents << [resource, *vals]
    end
  end

  #
  # Detect inconsistent data
  #
  def all_numeric_screen_name?()   screen_name =~ /\A\d+\z/  end
  def bad_chars_in_screen_name?()  screen_name !~ /\A\w*[A-Za-z_]\w*\z/  end
  def missing_id?()                self.twitter_user_id.nil?  end
  def missing_screen_name?()       screen_name.blank? || (screen_name =~ /^!bogus-/) end
  
  #
  # Emit data bundled for actual parsing
  #
  def finalize
    case
    when missing_screen_name?      then resource_prefix = 'bogus-no_screen_name-'
    when all_numeric_screen_name?  then resource_prefix = 'bogus-all_numeric-'
    when bad_chars_in_screen_name? then resource_prefix = 'bogus-bad_chars-'
    when missing_id?               then resource_prefix = 'bogus-missing_id-'
    else                                resource_prefix = ''
    end
    scraped_contents.each do |scraped_content|
      context, scraped_at, screen_name, page, _, *rest = scraped_content
      context = resource_prefix + context
      id      = twitter_user_id
      puts [context, scraped_at, id, page, screen_name, *rest].join("\t")
    end
  end
end


class InsertIdsStage2Script < Hadoop::Script
end
InsertIdsStage2Script.new(InsertIdsMapper, InsertIdsReducer).run

