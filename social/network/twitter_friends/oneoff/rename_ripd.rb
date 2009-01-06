#!/usr/bin/env ruby
require 'fileutils'; include FileUtils
$: << File.dirname(__FILE__)+'/lib'
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
    screen_name =~ /^!bogus-/
  end

  def finalize
    # filenames = scraped_files.map{|sf| sf.filename }.join(',')
    # puts [twitter_user_id, screen_name, filenames].join("\t")
    case
    when missing_screen_name?      then puts [:missing_screen_name,  screen_name, twitter_user_id].join("\t")
    when all_numeric_screen_name?  then puts [:all_numeric,          screen_name, twitter_user_id].join("\t")
    when bad_chars_in_screen_name? then puts [:bad_chars,            screen_name, twitter_user_id].join("\t")
    when missing_id?               then puts [:missing_id,           screen_name, twitter_user_id].join("\t")
    end
  end
end


Hadoop::Script.new(RenameMapper, RenameReducer).run




# NO_ID_FRIEND_DIR ='ripd/bogus/'
#   #
#   # collect all the filenames and the ID for a given user
#   #
#   def accumulate thing
#     case thing
#     when ScrapedFile
#       self.filenames << thing.filename
#     when TwitterUser, TwitterUserPartial
#       self.twitter_user_id = repair_user_id thing.id
#     end
#   end
#
#   # create a script to rename old files to new files
#   def emit
#     # some old files have no ID
#     if ! self.twitter_user_id
#       self.twitter_user_id = 0
#       id_not_found = true
#     end
#     # Zero-pad out ID
#     self.twitter_user_id = stringify_user_id(self.twitter_user_id)
#     # emit renamer script
#     self.filenames.each do |filename|
#       case
#       when id_not_found
#         filename = rename_to_bogus_dir(filename, NO_ID_FRIEND_DIR)
#       when all_numeric_username?(filename)
#         filename = rename_to_bogus_dir(filename, ALL_NUMERIC_SCREEN_NAME_DIR)
#       when !legit_filename?(filename)
#         filename = rename_to_bogus_dir(filename, NON_ALPHANUM_DIR)
#       end
#       new_filename = gsub(/\+(\d)-(\d+)\.json$/, "+\\1\\2+#{self.twitter_user_id}.json")
#       puts %Q{ mv '#{filename}' '#{new_filename}' }
#     end
#   end
#   #
#   # There are some files for expired users
#   # and some users with bogus
#   #
#   def rename_base_dir filename, base_dir
#     # eg  _20081224/users/show /user%3Fpage%3D69.json+200812240808.json
#     m = %r{.*/(\w+/\w+/\w+/[^/\.]+\.json\+\d{8}-\d{6}\.json)}.match filename
#     if !m then raise "Hell: bad match to filename #{filename}"  end
#     base_dir+$1
#   end
#
#   # Well-formed filename: has one non-numeric char, matches old-style date formate
#   LEGIT_FILE_NAME_RE = %r{.*/(\w+/\w+/\w+/(\w*[a-zA-Z_]\w*)%3Fpage%3D\d+\.json\+\d{8}-\d{6}\.json)}
#   #
#   # Some filenames have non-alpha characters
#   #   see bug report:
#   #
#   def legit_filename? filename
#     # eg  _20081224/users/show/user%3Fpage%3D69.json+200812240808.json
#     LEGIT_FILENAME_RE.match(filename)
#   end
#   # Match a username with only numbers
#   ALL_NUMERIC_USERNAME_RE =        %r{.*/(\w+/\w+/\w+/(\d+)%3Fpage%3D\d+\.json\+\d{8}-\d{6}\.json)}
#   #
#   # All-numeric IDs cause problems.  Can these be re-requested using their twitter_user_id?
#   #   see bug report:
#   #
#   def all_numeric_username? filename
#     ALL_NUMERIC_USERNAME_RE.match(filename)
#   end
# end
