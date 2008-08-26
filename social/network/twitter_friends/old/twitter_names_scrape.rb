#!/usr/bin/env ruby
require 'imw/utils'
require 'twitter_names_model'
include IMW; IMW.verbose = true
as_dset __FILE__

WGET_CMD     = "wget -x -nc -np -nv"
SLEEP_TIME_BETWEEN_REQS = 1

#
# Scrape down to followed level +threshold+ (ignoring names in +twitter_404s+)
#
def scrape_pass(threshold, twitter_404s)
  twitter_users = TwitterUser.load_users_index
  banner "Starting a new scrape: threshold #{threshold} - #{twitter_users.length} names, #{twitter_404s.length} inaccessible"
  twitter_users.each do |user|
    track_progress :name_and_popularity, "#{user.twitter_name[0..0].downcase} - #{user.n_followers}"
    #
    # skip if unpopular; if not public; or if we have it already
    #
    break if user.n_followers < threshold
    next if twitter_404s.include? user.twitter_name
    next if File.exist?(user.profile_page_filename)
    #
    # OK, get it.
    #
    wget_output = `#{WGET_CMD} http://twitter.com/#{user.twitter_name} -O #{user.profile_page_filename} 2>&1`.chomp
    if wget_output =~ /ERROR 404/ then twitter_404s << user.twitter_name end
    announce "%7d\t%-25s\t%s " % [user.n_followers, user.twitter_name, wget_output]
    #
    # throttle request rate
    #
    sleep SLEEP_TIME_BETWEEN_REQS
  end
end

#
# Calls the twitter_names_list script
#
def relist_names
  announce "Relisting names"
  announce `#{path_to(:me, "twitter_names_list.rb")}`.chomp
  announce "...done relisting"
end

#
# Track the non-public users across sessions
#
def load_404s
  if File.exist?(TwitterUser.err_404s_filename)
    DataSet.load(TwitterUser.err_404s_filename)
  else
    DataSet.new []
  end
end

#
# Scrape at various thresholds
#
twitter_404s = load_404s
([2, 1, 6,]*2 + [1]).flatten.each do |threshold|
  scrape_pass threshold, twitter_404s
  twitter_404s.dump TwitterUser.err_404s_filename
  relist_names
end
