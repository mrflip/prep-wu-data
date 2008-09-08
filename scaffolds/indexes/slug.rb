require 'rubygems'
require 'addressable/uri'
require 'uuidtools'

class Addressable::URI
  def revhost
    return host unless host =~ /\./
    host.split('.').reverse.join('.')
  end
end


module IMW
  # note: no trailing /
  UUID_INFOCHIMPS_NAMESPACE = UUID.sha1_create(UUID_URL_NAMESPACE, 'http://infochimps.org') unless defined?(UUID_URL_NAMESPACE)

  #
  #
  # +uniqname+ -- reasonable effort at a uniq-ish, but human-comprehensible string
  # Uniqname should only contain the characters A-Za-z0-9_-./
  #
  # +uuid+  -- RFC-4122 ver.5 uuid; guaranteed to be universally unique
  #
  # See
  #   http://www.faqs.org/rfcs/rfc4122.html
  #
  class Slug
    # A humane representation of the uniqname ('that-one-time-at_foo')
    attr_reader :uniqname
    # The purportedly unique string ('')
    attr_accessor :uniqish

    def initialize uniqname
      self.uniqname = uniqname
      self.uniqish  = uniqname
    end

    #
    # Unless overridden, use the uniqish to 
    # make a name-based UUID within the infochimps.org 
    # namespace
    #
    def uuid
      UUID.sha1_create(UUID_URL_NAMESPACE, full_uniqname)
    end

    # Uniqname with only \w characters -- safe for everything there be
    def url_sane
      return '' if !uniqname
      uniqname.gsub(/[^\w\/\:]+/, '-').gsub(/_/, '__').gsub(%r{[/:]+}, '_')
    end
    
    def uniqname= t
      @uniqname = self.class.sanitize_uniqname(t)
    end

    # Strip all but uniqname-safe characters
    def self.sanitize_uniqname t, turd='-'
      t = t.gsub(%r{[^\w\-\./]+}, turd)
    end
  end

  #
  # Uses a URL (that's locator, not URI) as a
  # presumed-uniq identifier.  
  #
  # +uniqish+ returns the full normalized URL
  #
  # +uniqname+ is formed from the dot-reversed host, the scheme (if not http) and a
  # sanitized version of the path. (The query string, fragment, etc are stripped
  # from the uniqname)
  #
  #
  class URLSlug < Slug
    attr_accessor :url
    def initialize url_str
      self.url     = Addressable::URI.heuristic_parse(url_str).normalize
      raise "Bad URL #{url}" unless url.host
      self.uniqish = url.to_s
      self.uniqname   = munge_url
    end

    def munge_url 
      host         = url.revhost.gsub(/[^a-zA-Z0-9\.\-]+/, '')  # note: no _
      host        += ':'+url.scheme unless (url.scheme=='http')
      path         = url.path
      path         = path.gsub(%r{;[^/]*/}, '/').gsub(%r{;[^/]*$}, '') # Kill off path query (;) parts, in middle or at end
      path         = path.gsub(%r{/+$}, '').gsub(%r{^/+}, '')          # Kill leading & trailing /
      [host, path].reject(&:blank?).join('/')
    end
    
    def uuid
      UUID.sha1_create(UUID_URL_NAMESPACE, full_uniqname)
    end
  end
end



module Sluggable
  protected
  def create_slug
    "Slugging #{self.attributes}"
    if (self.class.slug_on == :url) || (self.name.blank?)
      slug = IMW::URLSlug.new(self.url)
      self.name = slug.uniqname
    else
      slug = IMW::Slug.new(self.name)
    end
    self.uniqname ||= slug.uniqname
  end
  public

  def self.included base
    base.before :save, :create_slug
    base.class_eval do
      def self.slug_on s=nil
        @slug_on ||= s
      end
    end
  end
end
