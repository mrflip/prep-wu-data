#!/usr/bin/env ruby
require "rubygems"
require 'imw/utils'; include IMW; IMW.verbose = true
require 'twitter_names_model'
as_dset __FILE__
require "YAML"

TWITTER_NAME_RE = %r{^ +<a href="http://twitter.com/([^"]+)" class="url" rel="contact"} #"
def extract_following(user)
  puts "\t...people #{user.twitter_name} is following"
  File.open(user.following_filename, "w") do |following_file|
    File.open(user.profile_page_filename){|f| f.readlines }.each do |line|
      if line =~ TWITTER_NAME_RE
        following_file << "#{$1}\n"
      end
    end
  end
end

twitter_followers = {}
TwitterUser.users_with_profile do |user|
  track_progress :profile, File.basename(user.following_filename)[0..0].downcase
  unless File.exist? user.following_filename
    extract_following(user)
  end
  File.open(user.following_filename){|f| f.readlines }.each do |followed_name|
    followed_name.chomp!
    twitter_followers[followed_name] ||= 0
    twitter_followers[followed_name]  += 1
  end
end
twitter_followers = twitter_followers.sort_by{ |follower, n| [-n, follower] }
DataSet.dump({ :names => twitter_followers }, TwitterUser.names_index_filename)
