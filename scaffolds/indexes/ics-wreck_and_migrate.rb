#!/usr/bin/env ruby
require  File.dirname(__FILE__)+'/ics-models.rb'
require 'fileutils'; include FileUtils

# #
# # Wipe DB and add new migration
# #
DataMapper.auto_migrate!


# Destroy old
announce "Destroying old"
# Info, Search, Talk,
[Contributor, Credit, Dataset, Tagging, Tag, Field, Link, Note, Payload, Rating, RightsStatement, License, User].each do |klass|
  klass.all.each{ |l| l.destroy }
end


License.find_or_create(
  :name => 'Needs Clarification of Rights and Restrictions',
  :uniqname => :needs_rights,
  :desc => 'Open Data exchange requires that the wishes of those who gathered the data are respected, and that those who use it have clarity about the restrictions each resource carries.

This dataset lacks any statement about its rights and restrictions.  You can help by looking in the source for either an explicit license or a statement of terms, and pasting that information here.',
  :license_url => 'http://infochimps.org/help/license')


# raise "Skipped! Uncomment!"


