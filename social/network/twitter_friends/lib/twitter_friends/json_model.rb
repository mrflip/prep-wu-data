require 'rubygems'; require 'json'
require 'hadoop/utils' ; include Hadoop
require 'twitter_friends/twitter_user'
require 'twitter_friends/twitter_model_common'

#
# The JSON user records come off the wire a bit more heavyweight than we'd like.
#
# We vertically partition the single user record into three, as described above:
# one with the fundamental info, one with user's personal info (name, location,
# etc) and one with the styling they've applied to their homepage.
#
# A sample JSON file, reformatted for clarity:
#
#    {
#      "id"                           : 14693823,
#      // scraped_at added in processing
#      "screen_name"                  : "MarsPhoenix"
#      "protected"                    : false,
#      "followers_count"              : 39452,
#      "friends_count"                : 3,
#      "statuses_count"               : 609,
#      "favourites_count"             : 5,
#      "created_at"                   : "Thu May 08 00:17:54 +0000 2008",
#
#      // "id"                        : 14693823,
#      // scraped_at added in processing
#      "name"                         : "MarsPhoenix",
#      "url"                          : "http:\/\/tinyurl.com\/5wwaru",
#      "location"                     : "Mars, Solar System",
#      "description"                  : "I dig Mars! ",
#      "time_zone"                    : "Pacific Time (US & Canada)",
#      "utc_offset"                   : -28800,
#
#      // "id"                        : 14693823,
#      // scraped_at added in processing
#      "profile_background_color"     : "9ae4e8",
#      "profile_text_color"           : "000000",
#      "profile_link_color"           : "0000ff",
#      "profile_sidebar_border_color" : "87bc44",
#      "profile_sidebar_fill_color"   : "e0ff92",
#      "profile_background_tile"      : true,
#      "profile_image_url"            : "http:\/\/s3.amazonaws.com\/twitter_production\/profile_images\/55133915\/PIA09942_normal.jpg",
#      "profile_background_image_url" : "http:\/\/s3.amazonaws.com\/twitter_production\/profile_background_images\/3069906\/PSP_008591_2485_RGB_Lander_Detail_516-387.jpg",
#
#      // Sometimes:
#      "status"                       :  { ... a tweet record: see tweet.tsv ... }
#
#    }
#
module JsonUser
  # ===========================================================================
  #
  # Make the data easier for batch flat-record processing
  #
  def self.repair_json_hsh hsh
    hsh['created_at'] = TwitterModelCommon.flatten_date(hsh['created_at'])
    hsh['id']         = TwitterModelCommon.zeropad_id(hsh['id'])
    hsh['protected']  = TwitterModelCommon.unbooleanize(hsh['protected'])
    scrub_hash hsh, :name, :location, :description, :url
    hsh
  end

  #
  # Expand a user .json record into model instances
  #
  # Ex.
  #   # Parse a complete twitter users/show/foo.json record
  #   twitter_user, twitter_user_profile, twitter_user_style =
  #     JsonUser.new_user_models json_str, scraped_at, TwitterUser, TwitterUserProfile, TwitterUserStyle
  #
  #   # just get the id and screen_name
  #   JsonUser.new_user_models json_str, scraped_at, TwitterUserId
  #
  def self.new_user_models json_str, scraped_at, *klasses
    begin
      hsh = JSON.load(json_str) or return []
    rescue Exception => e; return [] ; end
    hsh = repair_json_hsh hsh
    hsh['scraped_at'] = scraped_at
    klasses.map do |klass|
      klass.from_hash(hsh)
    end
  end
end

module JsonTweet
  # ===========================================================================
  #
  # Make the data easier for batch flat-record processing
  #
  def self.repair_json_hsh hsh
    hsh['created_at'] = TwitterModelCommon.flatten_date(hsh['created_at'])
    hsh['id']         = TwitterModelCommon.zeropad_id(hsh['id'])
    hsh['protected']  = TwitterModelCommon.unbooleanize(hsh['protected'])
    scrub_hash hsh, :name, :location, :description, :url
    hsh
  end

  def self.parse_source tweet_source
    # fromsource_raw = tweet_hsh['source']
    if ! tweet_source_raw.blank?
      if m = %r{<a href="([^\"]+)">([^<]+)</a>}.match(tweet_source_raw)
        tweet_hsh['fromsource_url'], tweet_hsh['fromsource'] = m.captures
      else
        tweet_hsh['fromsource'] = tweet_source_raw
      end
    end

  end

  #
  # Expand a user .json record into model instances
  #
  # Ex.
  #   # Parse a complete twitter users/show/foo.json record
  #   twitter_user, twitter_user_profile, twitter_user_style =
  #     JsonUser.new_user_models json_str, scraped_at, TwitterUser, TwitterUserProfile, TwitterUserStyle
  #
  #   # just get the id and screen_name
  #   JsonUser.new_user_models json_str, scraped_at, TwitterUserId
  #
  def self.new_user_models json_str, scraped_at, *klasses
    begin
      hsh = JSON.load(json_str) or return []
    rescue Exception => e; return [] ; end
    hsh = repair_json_hsh hsh
    hsh['scraped_at'] = scraped_at
    klasses.map do |klass|
      klass.from_hash(hsh)
    end
  end
end
