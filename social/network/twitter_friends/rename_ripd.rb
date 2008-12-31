#!/usr/bin/env ruby
require 'rubygems'
include FileUtils
#require 'imw' ; include IMW; as_dset __FILE__

#
# * collect IDs
#

def map line
  # twitter_user: emit screen_name => id

  # scraped file: emit screen_name => filename
end

NO_ID_FRIEND_DIR ='ripd/bogus/'
class RenameReducer < Hadoop::AccumulatingStreamer
  attr_accessor :twitter_user_id, :filenames
  def initialize
    self.twitter_user_id = nil
    self.filenames       = []
  end
  #
  # collect all the filenames and the ID for a given user
  #
  def accumulate thing
    case thing
    when ScrapedFile
      self.filenames << thing.filename
    when TwitterUser, TwitterUserPartial
      self.twitter_user_id = repair_user_id thing.id
    end
  end

  # create a script to rename old files to new files
  def emit
    # some old files have no ID
    if ! self.twitter_user_id
      self.twitter_user_id = 0
      id_not_found = true
    end
    # Zero-pad out ID
    self.twitter_user_id = stringify_user_id(self.twitter_user_id)
    # emit renamer script
    self.filenames.each do |filename|
      case
      when id_not_found
        filename = rename_to_bogus_dir(filename, NO_ID_FRIEND_DIR)
      when all_numeric_username?(filename)
        filename = rename_to_bogus_dir(filename, ALL_NUMERIC_SCREEN_NAME_DIR)
      when !legit_filename?(filename)
        filename = rename_to_bogus_dir(filename, NON_ALPHANUM_DIR)
      end
      new_filename = gsub(/\+(\d)-(\d+)\.json$/, "+\\1\\2+#{self.twitter_user_id}.json")
      puts %Q{ mv '#{filename}' '#{new_filename}' }
    end
  end
  #
  # There are some files for expired users
  # and some users with bogus
  #
  def rename_base_dir filename, base_dir
    # eg  _20081224/users/show /user%3Fpage%3D69.json+200812240808.json
    m = %r{.*/(\w+/\w+/\w+/[^/\.]+\.json\+\d{8}-\d{6}\.json)}.match filename
    if !m then raise "Hell: bad match to filename #{filename}"  end
    base_dir+$1
  end

  # Well-formed filename: has one non-numeric char, matches old-style date formate
  LEGIT_FILE_NAME_RE = %r{.*/(\w+/\w+/\w+/(\w*[a-zA-Z_]\w*)%3Fpage%3D\d+\.json\+\d{8}-\d{6}\.json)}
  #
  # Some filenames have non-alpha characters
  #   see bug report:
  #
  def legit_filename? filename
    # eg  _20081224/users/show/user%3Fpage%3D69.json+200812240808.json
    LEGIT_FILENAME_RE.match(filename)
  end
  # Match a username with only numbers
  ALL_NUMERIC_USERNAME_RE =        %r{.*/(\w+/\w+/\w+/(\d+)%3Fpage%3D\d+\.json\+\d{8}-\d{6}\.json)}
  #
  # All-numeric IDs cause problems.  Can these be re-requested using their twitter_user_id?
  #   see bug report:
  #
  def all_numeric_username? filename
    ALL_NUMERIC_USERNAME_RE.match(filename)
  end
  #
  # zero-pad to ten characters (enough for
  #
  def stringify_user_id id
    "%010d"%[id.to_i]
  end
end
