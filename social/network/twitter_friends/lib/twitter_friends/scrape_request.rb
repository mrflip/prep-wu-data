#
#
# REMEMBER TO ADD ITERATION TO scrape_requests
# move public feed to http://twitter.com/statuses/public_timeline
# tier the ripd/ directories
#



require 'imw/chunk_store/cached_uri'
require 'imw/chunk_store/scrape'

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
  # The URI for a given resource
  #
  def uri
    "http://twitter.com/#{resource_path}/#{identifier}.json?page=#{page}"
  end
  # Regular expression to grok resource from uri
  GROK_URI_RE = %r{http://twitter.com/(\w+/\w+)/(\w+)\.json\?page=(\d+)}
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

  # Context <=> resource mapping
  #
  # aka. repairing the non-REST uri's
  RESOURCE_PATH_FROM_CONTEXT = {
    :followers => 'statuses/followers', :friends => 'statuses/friends', :user => 'users/show'
  }
  # Get url resource for context
  def resource_path
    RESOURCE_PATH_FROM_CONTEXT[context]
  end
  # Get context from url resource
  def self.context_for_resource(resource)
    RESOURCE_PATH_FROM_CONTEXT.invert[resource]
  end
end
