#
#
# REMEMBER TO ADD ITERATION TO scrape_requests
# move public feed to http://twitter.com/statuses/public_timeline
# tier the ripd/ directories
#

class ScrapeRequest
  attr_accessor :identifier, :context, :page

  #
  # Create a ScrapeRequest from an identifier, context and page
  #
  def initialize identifier, context, page, scraped_at=nil
    self.identifier = identifier
    self.context    = context.to_sym
    self.page       = page
    self.cached_uri = CachedUri.new(rip_uri, scraped_at)
  end

  #
  # Create a ScrapeRequest from a URI string.
  #
  def self.new_from_uri uri_str, scraped_at
    m = GROK_URI_RE.match(uri_str)
    unless m then warn "Can't grok uri #{uri_str}"; return nil; end
    resource, identifier, page = m.captures
    context = context_for_resource(resource)
    self.new identifier, context, page, scraped_at
  end

end
