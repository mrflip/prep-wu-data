#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'imw/extract/hpricot'
require 'imw/utils'
require 'imw/dataset/datamapper'
require 'fileutils' ; include FileUtils
require 'json'
include IMW; IMW.verbose = true
as_dset __FILE__

#
# Setup database
#

#DataMapper::Logger.new(STDOUT, :debug) # watch SQL log -- must be BEFORE call to db setup
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
IMW::DataSet.setup_remote_connection dbparams
require 'twitter_profile_model'

#
# wget url_to_get, ripd_file, sleep_time
#
# Crudely scrape a url
#
# get the url
# leave a 0-byte turd on failure to prevent re-fetching; use find ripd/ -size 0 --exec rm {} \; to scrub
# sleeps for sleep_time
#
def wget rip_url, ripd_file=nil, sleep_time=30
  ripd_file ||= rip_url
  cd path_to(:ripd_root) do
    mkdir_p   File.dirname(ripd_file)
    if File.exists?(ripd_file) then return end # puts "Skipping #{rip_url}" ;
    print `wget -nv -O"#{ripd_file}" "#{rip_url}" `
    success = File.exists?(ripd_file)
    FileUtils.touch        ripd_file  # leave a 0-byte turd so we don't refresh
    sleep sleep_time
    return success
  end
end

class User
  def self.announce_stats prefix=''
    total       = User.count()
    unrequested = User.count(:scraped => nil) # this gives a bogus value, dunno why
    unparsed    = User.count :parsed  => nil
    banner "#{prefix} :: %7s total names :: %7s unrequested :: %7s unparsed" % [total, requested, unparsed]
  end
end


def scrape_pass threshold, offset = 0
  # User.announce_stats("Scraping %6d..%-6d for popular+unrequested users" % [offset, threshold+offset])
  popular_and_neglected = User.all :requested => nil, 
     :fields => [:twitter_name, :followers_count, :requested, :scraped, :parsed, :id],
     :order  => [:followers_count.desc], 
     :limit  => threshold, :offset => offset
  popular_and_neglected.each do |user|
    track_progress :popularity, "#{user.followers_count}"
    track_count    :users, 200
    success = wget user.rip_url, user.ripd_file, 60
    # mark columns
    requested = File.exists?(user.ripd_file)
    scraped   = requested && (File.size(user.ripd_file) != 0)
    user.requested = requested ? true : nil  # ugh. FIXME (col. has wrong default, don't want to remigrate.)
    user.scraped   = scraped   ? true : nil
    # announce [requested, scraped, user.ripd_file].join("\t")
    user.save
  end
  announce "Finished chunk %6d..%-6d" % [offset, threshold+offset]
end

n_users = User.count
chunksize = 1000
chunks    = (n_users / chunksize).to_i + 1
(0..chunks).each do |chunk|
  scrape_pass 1000, chunk * chunksize
end
