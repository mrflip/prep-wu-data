#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/../lib'
require 'hadoop/tsv'
require 'hadoop/utils'
require 'hadoop/script'
require 'hadoop/streamer'
require 'twitter_friends/scraped_file'
# require 'twitter_friends/json_model'

#
# * collect IDs
#

class RenameMapper < Hadoop::Streamer
  def process resource, *vals
    case
    when resource == 'twitter_user_id'
      id, screen_name = vals
      if ! screen_name then screen_name = "!BOGUS-#{id}" end
    when resource =~ /^scraped_file.*/
      screen_name = vals[2]
      resource = 'scraped_file' unless ['scraped_file_bogus', 'scraped_file_zerolen'].include?(resource)
    else raise "Don't know what to do with #{[resource, *vals].inspect}"
    end
    puts [(screen_name||'').downcase, resource, *vals].join("\t")
  end
end


class RenameReducer < Hadoop::AccumulatingStreamer
  attr_accessor :screen_name, :twitter_user_id, :scraped_files
  def reset!
    super
    self.twitter_user_id = nil
    self.scraped_files   = []
  end

  def accumulate key, resource, *vals
    self.screen_name = key
    case
    when resource == 'twitter_user_id'
      self.twitter_user_id = vals[0]
    when resource =~ /^scraped_file.*/
      self.scraped_files << ScrapedFile.new(*vals)
    else raise "Don't know what to do with #{[key, resource, *vals].inspect}"
    end
  end

  def all_numeric_screen_name?
    screen_name =~ /\A\d+\z/
  end

  def bad_chars_in_screen_name?
    screen_name !~ /\A\w*[A-Za-z_]\w*\z/
  end

  def missing_id?
    self.twitter_user_id.nil?
  end

  def missing_screen_name?
    screen_name.blank? || (screen_name =~ /^!bogus-/)
  end

  def finalize
    case
    when missing_screen_name?      then new_root = 'bogus/no_screen_name'
    when all_numeric_screen_name?  then new_root = 'bogus/all_numeric'
    when bad_chars_in_screen_name? then new_root = 'bogus/bad_chars'
    when missing_id?               then new_root = 'bogus/missing_id'
    else                                new_root = 'new'
    end
    scraped_files.each do |scraped_file|
      scraped_file.moreinfo = twitter_user_id
      mvcmd = "mv %-110s %s/%-110s" % [scraped_file.filename, new_root, scraped_file.gen_scraped_filename]
      key   = "ripd-%s-%s.tar.bz2" % [ scraped_file.scrape_session, scraped_file.resource_path.gsub(%r{/}, '-')]
      puts [key, mvcmd].join("\t")
    end
  end
end

Hadoop::Script.new(RenameMapper, RenameReducer).run
