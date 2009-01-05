require 'twitter_friends/twitter_model_common'
require 'twitter_friends/scrape/twitter_api'
require 'rubygems'
require 'addressable/uri'

#
# Info about a raw scraped file. Once fresh off the servers, now forever frozen
# in time, monument to a bygone age.
#
#
class ScrapedFile < Struct.new(
    :scrape_session, :context, :identifier, :page,
    :size, :scraped_at, :filename )
  include TwitterModelCommon
  include TwitterApi
  attr_accessor :bogus
  def resource_name
    case
    when self.bogus          then :scraped_file_bogus
    when self.size.to_i == 0 then :scraped_file_zerolen
    else                          'scraped_file-' + (identifier[0..1]||'').downcase end
  end

  #
  # Filename for the scraped URI
  #
  def set_filename!
    self.filename = "#{resource_path}/#{identifier}.json%3Fpage%3D#{page}+#{scraped_at}.json"
  end

  #
  # Pull file info from a flat listing.
  # individually querying for file metadata violates idempotency,
  # We instead freeze scraped directories, take a static listing
  # and draw metadata from there.
  #
  # tar tvjf foo.tar.bz2
  # -rw-r--r-- flip/flip       134 2008-12-23 17:29 path1/path2/foo.bar
  # ls -l path1/path2/foo.bar
  # -rw-r--r-- 1 flip wheel  67743 2008-12-24 13:25 path1/path2/foo.bar
  def self.new_from_ls_line line, format=:tar
    vals = line.chomp.split(/\s+/)
    case format
    when :tar then mode,    owner_group,  size, dt, tm, filename = vals
    when :ls  then mode, _, owner, group, size, dt, tm, filename = vals
    else raise "Need a format string: got #{format.inspect}"
    end
    if !filename then warn "Ill-formed 'ls' line #{line}"; return nil ; end
    self.new_from_filename(filename, size) or return nil
  end


  GROK_FILENAME_RE = %r{com\.twitter/_(\d{8})/([\w/]+)/((?:%5F|\w)\w*)\.json%3Fpage%3D(\d+)\+([\d\-]+)\.json}
  def self.new_from_filename filename, size
    m = GROK_FILENAME_RE.match(filename)
    if ! m then warn "Can't grok filename #{filename}"; return self.new_from_bogus(filename, size); end
    scrape_session, resource, identifier, page, scraped_at = m.captures
    # extract field values
    identifier = Addressable::URI.unencode_component(identifier)
    context = context_for_resource(resource) or raise("Wrong resource specification #{resource} for '#{filename}'")
    # instantiate
    self.new scrape_session, context, identifier, page, size, scraped_at, filename
  end

  GROK_BOGUS_FILENAME_RE = %r{com\.twitter/_(\d{8})/([\w/]+)/(.*)\.json%3Fpage%3D(.*)\+([\d\-]+)\.json}
  def self.new_from_bogus filename, size
    m = GROK_BOGUS_FILENAME_RE.match(filename)
    if m
      scrape_session, resource, identifier, page, scraped_at = m.captures
    else
      scrape_session, resource, identifier, page, scraped_at = []
    end
    context = context_for_resource(resource)
    scraped_file = self.new scrape_session, context, identifier, page, size, scraped_at, filename
    scraped_file.bogus = true
    scraped_file
  end

end
