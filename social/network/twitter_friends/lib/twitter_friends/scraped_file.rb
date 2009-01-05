require 'forwardable'

#
# Info about a raw scraped file. Once fresh off the servers, now forever frozen
# in time, monument to a bygone age.
#
#

# class ScrapedFile < Struct.new(
#     :screen_name, :context,
#     :page, :size, :scrape_session )
#   include TwitterModelCommon
#
# end

class ScrapedFile
  attr_accessor :size, :scraped_at
  def_delegators :scrape_request, :identifier, :context, :resource, :page
  def initialize scrape_request, size, scraped_at
    self.scrape_request = scrape_request
    self.size           = size
    self.scraped_at     = scraped_at
  end

  #
  # Filename for the scraped URI
  #
  def filename
    "#{resource_path}/#{identifier}.json%3Fpage%3D#{page}+#{scraped_at}.json"
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
    vals = line.split(/\s+/)
    case format
    when :tar then mode,    owner_group,  size, dt, tm, filename = vals
    when :ls  then mode, _, owner, group, size, dt, tm, filename = vals
    else raise "Need a format string: got #{format.inspect}"
    end
    if !filename then warn "Ill-formed 'ls' line #{line}"; return nil ; end
    self.new_from_filename(filename, size) or return nil
  end


  GROK_FILENAME_RE = %r{(\w+/\w+)/(\w+)\.json%3Fpage#3D(\d+)+([\d\-]+)\.json}
  def self.new_from_filename filename_str
    m = GROK_FILENAME_RE.match(filename_str)
    unless m then warn "Can't grok filename #{filename_str}"; return nil; end
    resource, identifier, page, scraped_at = m.captures
    context = context_for_resource(resource)
    self.new identifier, context, page, scraped_at
  end

  def item_key
    [identifier, context, page].join('-')
  end
end
