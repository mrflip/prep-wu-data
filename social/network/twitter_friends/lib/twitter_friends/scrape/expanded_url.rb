require 'net/http'

module TwitterFriends
  module Scrape
    include TwitterFriends::StructModel::ModelCommon

    #
    # We don't really care here whether the URLs do anything, but we don't want
    # crazy characters (which /can/ come off the wire).  This Regex should scrub
    # out stuff that just absosmurfly doesn't belong.
    #
    
    
    class ExpandedUrl < Struct.new(:src_url, :dest_url, :scraped_at)
      # src_url uniquely identifies us
      def num_key_fields() 1  end

      # Anything not in these two categories doesn't belong in a URL.
      RE_URL_SANE_CHARS = 
        Addressable::URI::CharacterClasses::UNRESERVED + 
        Addressable::URI::CharacterClasses::RESERVED
      #
      # Replace all url-insane characters by their %encoding
      #
      # This code is stolen from Addressable::URI, which unfortunately has a bug
      # in exactly this method (fixed here). (http://addressable.rubyforge.org)
      #
      def self.scrub_url url
        url.gsub(/[^#{RE_URL_SANE_CHARS}]/) do |sequence|
          (sequence.unpack('C*').map { |c| "%" + ("%02x"%c).upcase }).join("")
        end
      end

      #
      # We want to generously include all expanded urls in the full range from
      # canonical to htttp://htpp//glori.ou.slycom/stupid and&ill&formed.html
      # while being minimally intrusive, and without sacrificing the common case
      # (of a well-formed URL)
      #
      # So we need to nuke non-ascii and control characters 
      #
      
      #
      # We're not going to be subtle here.  There's an allowed set of 
      # characters in a URL, and in practice 
      #
      def self.normalize url
        begin
          url.gsub!(/ /, '%20')
          url.gsub!(/%([a-z].|.[a-z])/){|s| s.upcase}
          Addressable::URI.parse(url).normalize.to_s
        rescue Exception => e
          e.to_s
        end
      end
      
      #
      # Keep only insane characters; encode
      #
      def self.insane_chars url
        # insane = url.gsub(/[#{RE_URL_SANE_CHARS}"\\]+/, '')
        # Hadoop.encode_str(insane)
        Addressable::URL
      end

      #
      # Handle some known edge cases / simplifications with short urls
      #
      def fix_src_url!
      end
      #
      # is.gd urls use a terminal '-' to indicate 'preview' -- but
      # we want the destination, so strip that.
      #
      def fix_isgd_url!
        self.src_url.gsub!(%r{(http://is.gd/\w+)[-/]}, '\1')
      end

      def fetch_dest_url!
        return unless dest_url.blank? && scraped_at.blank?
        fix_src_url!
        begin
          # look for the redirect
          self.dest_url = Net::HTTP.get_response(URI.parse(src_url))["location"]
          self.dest_url.gsub
        rescue Exception => e
          nil
        end
        self.scraped_at = TwitterFriends::StructModel::ModelCommon.flatten_date(Time.now) if self.scraped_at.blank?
      end

    end
  end
end
