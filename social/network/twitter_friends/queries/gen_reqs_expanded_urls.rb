#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../lib'

require 'hadoop'                       ; include Hadoop
require 'twitter_friends/struct_model' ; include TwitterFriends::StructModel
require 'twitter_friends/scrape'       ; include TwitterFriends::Scrape

#
# See bundle.sh for running pattern
#

module GenReqsExpandedUrls
  class Mapper < Hadoop::StructStreamer
    #
    #
    def process thing
      next unless thing.is_a?(ExpandedUrl)
      # insane = TwitterFriends::Scrape::ExpandedUrl.insane_chars(thing.dest_url)
      # puts [thing.src_url, insane, thing.scraped_at].join("\t") unless insane.blank?
      normalized = TwitterFriends::Scrape::ExpandedUrl.normalize(thing.dest_url)
      if normalized != thing.dest_url
        puts [thing.src_url, thing.dest_url, thing.scraped_at, normalized].join("\t") 
      end
    end
  end

  class Script < Hadoop::Script
    # def reduce_command
    #   '/usr/bin/uniq -c'
    # end
  end
end

#
# Executes the script
#
GenReqsExpandedUrls::Script.new(GenReqsExpandedUrls::Mapper, nil).run
