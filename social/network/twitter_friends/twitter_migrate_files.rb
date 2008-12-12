#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
as_dset __FILE__
require 'fileutils'; include FileUtils
#

require 'imw/chunk_store/cached_uri'
require 'imw/chunk_store/scrape'
class TwitterScrapeFile
  include ScrapeFile
  attr_accessor :screen_name, :context, :page, :cached_uri
  
  #
  # Create from a screen_name, context and page number
  #
  def initialize screen_name, context, page, timestamp=nil
    self.screen_name = screen_name
    self.context    = context
    self.page       = page
    self.cached_uri = CachedUri.new(rip_uri, timestamp)
  end
  
  #
  # The URL for a given resource
  #
  def rip_uri
    "http://twitter.com/#{resource_path}/#{screen_name}.json?page=#{page}"
  end
  
  # Map context to url resource
  RESOURCE_PATH_FROM_CONTEXT = { 
    :followers => 'statuses/followers', :friends => 'statuses/friends', :user => 'users/show'
  }
  # Map context to url resource  
  def resource_path
    RESOURCE_PATH_FROM_CONTEXT[context]
  end

  #
  # CachedUri supplies the file path scheme
  #
  def file_path
    cached_uri.file_path
  end
  
  #
  # Using no timestamp and old cascading scheme
  #
  def old_ripd_file
    base_path = "_com/_tw/com.twitter/#{resource_path}"
    prefix    = (screen_name+'.')[0..1]
    slug_path = "_" + prefix.downcase
    filename  = "#{screen_name}.json%3Fpage%3D#{page}"
    path_to(:ripd_root, base_path, slug_path, filename) # :ripd_root
  end
  
  # Recognize old file paths
  RIPD_FILE_RE = %r{_com/_tw/com.twitter/(\w+/\w+)/_\w[\w\.]/(\w+)\.json%3Fpage%3D(\d+)}
  # 
  # create a scrape_file for an existing file
  #
  def self.new_from_old_ripd_file filename
    m = RIPD_FILE_RE.match(filename)
    unless m then warn "Can't grok filename #{filename}"; return nil; end
    timestamp = File.mtime(filename) if File.exists?(filename)
    resource, screen_name, page = m.captures
    context = RESOURCE_PATH_FROM_CONTEXT.invert[resource]
    scrape_file = self.new screen_name, context, page, timestamp
    scrape_file
  end
end


#
# Walk all files in the scraped directory and copy them to the new (correct) file scheme
#
def mass_migrate_files
  cd path_to(:ripd_root) do
    Dir["_com/_tw/com.twitter/*/*"].each do |resource|
      Dir["#{resource}/_*"].sort.each do |dir|
        Dir["#{dir}/*"].each do |ripd_file|
          track_count dir, 1_000
          scrape_file = TwitterScrapeFile.new_from_old_ripd_file(ripd_file) or next
          mkdir_p File.dirname(scrape_file.file_path), :verbose => false
          mv ripd_file, scrape_file.file_path, :verbose => false
        end
      end
    end
  end
end
mass_migrate_files


# # 
# puts cu.uri.to_s
# puts cu.url_from_file_path(cu.file_path)
