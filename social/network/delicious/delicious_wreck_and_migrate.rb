#!/usr/bin/env ruby
require  File.dirname(__FILE__)+'/delicious_link_models.rb'
require 'fileutils'; include FileUtils
require 'imw/utils'; include IMW; IMW.verbose = true
require 'imw/dataset/datamapper/uri'

# #
# # Wipe DB and add new migration
# #
# DataMapper.auto_migrate!
#
#
# # Destroy old
# announce "Destroying old"
# [DeliciousLink, Socialite, Tag, Tagging, SocialitesTag, SocialitesLink, Friendship].each do |klass|
#   klass.all.each{ |l| l.destroy }
# end

raise "Skipped! Uncomment!"
