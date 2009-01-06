require 'rubygems'; require 'json'
require 'hadoop/utils' ; include Hadoop
require 'twitter_friends/twitter_user'
require 'twitter_friends/tweet'
require 'twitter_friends/twitter_model_common'

class JsonParser
  attr_accessor :raw
  def initialize raw
    self.raw = raw
    self.fix_raw!
  end

  #
  # Coerce any fields that need fixin'
  #
  def fix_raw!
  end

  #
  # Safely parse the json object and instantiate with the raw hash
  #
  def self.new_from_json json_str, *args
    return unless json_str
    begin
      raw = JSON.load(json_str) or return
    rescue Exception => e; return ; end
    self.new raw, *args
  end
end

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
class JsonUser < JsonParser
  def initialize raw, scraped_at
    super raw
    self.raw['scraped_at'] = scraped_at
  end
  def healthy?() raw && raw.is_a?(Hash) end

  # user id from the raw hash
  def twitter_user_id
    raw['twitter_user_id']
  end

  # ===========================================================================
  #
  # Make the data easier for batch flat-record processing
  #
  def fix_raw!
    raw['created_at'] = TwitterModelCommon.flatten_date(raw['created_at'])
    raw['id']         = TwitterModelCommon.zeropad_id(raw['id'])
    raw['protected']  = TwitterModelCommon.unbooleanize(raw['protected'])
    scrub_hash raw, :name, :location, :description, :url
  end

  # ===========================================================================
  #
  #
  # Expand a user .json record into model instances
  #
  # Ex.
  #   # Parse a complete twitter users/show/foo.json record
  #   twitter_user, twitter_user_profile, twitter_user_style =
  #     JsonUser.generate_user_classes TwitterUser, TwitterUserProfile, TwitterUserStyle
  #
  #   # just get the id and screen_name
  #   JsonUser.generate_user_classes TwitterUserId
  #
  def generate_user_classes *klasses
    return [] unless healthy?
    klasses.map do |klass|
      klass.from_hash(raw)
    end
  end
  #
  # Create TwitterUser, TwitterUserProfile, and TwitterUserStyle
  # instances from this hash
  #
  def generate_user_profile_and_style
    generate_user_classes TwitterUser, TwitterUserProfile, TwitterUserStyle
  end
  #
  # Create TwitterUserPartial from this hash -- use this when you only have a
  # partial listing, for instance in the public timeline or another user's
  # followers list
  #
  def generate_user_partial
    generate_user_classes(TwitterUserPartial).first
  end
  #
  # produce the included last tweet
  #
  def generate_tweet
    raw_tweet = raw['status']
    JsonTweet.new(raw_tweet, twitter_user_id).generate_tweet
  end
end


#
# The JSON tweets records come off the wire a bit more heavyweight than we'd like.
#
# A sample JSON file, reformatted for clarity:
#
#
# {
#   "id"                           : 1012519767,
#   "created_at"                   : "Wed Nov 19 07:16:58 +0000 2008",
#   // twitter_user_id
#   "favorited"                    : false,
#   "truncated"                    : false,
#   "in_reply_to_user_id"          : null,
#   "in_reply_to_status_id"        : null,
#   "text"                         : "[Our lander (RIP) had the best name. The next rover to Mars, @MarsScienceLab, needs a name. A contest for kids: http:\/\/is.gd\/85rQ  ]"
#   "source"                       : "web",
# }
#
class JsonTweet < JsonParser
  def initialize raw, twitter_user_id = nil
    super raw
    if twitter_user_id
      raw['twitter_user_id'] = twitter_user_id
    elsif raw['user'] && raw['user']['id']
      raw['twitter_user_id'] = TwitterModelCommon.zeropad_id( raw['user']['id'] )
    end
  end
  def healthy?() raw && raw.is_a?(Hash) end

  # ===========================================================================
  #
  # Make the data easier for batch flat-record processing
  #
  def fix_raw!
    raw['id']         = TwitterModelCommon.zeropad_id(  raw['id'])
    raw['created_at'] = TwitterModelCommon.flatten_date(raw['created_at'])
    raw['favorited']  = TwitterModelCommon.unbooleanize(raw['favorited'])
    raw['truncated']  = TwitterModelCommon.unbooleanize(raw['truncated'])
    scrub_hash raw, :text
  end

  def generate_tweet
    return unless healthy?
    Tweet.from_hash(raw)
  end
  #
  # produce the included last tweet
  #
  def generate_user_partial
    raw_user = raw['user']
    JsonUser.new(raw_user, raw['created_at']).generate_user_partial
  end
end

# Public timeline is an array of users with one tweet each
class JsonPublicTimeline < JsonParser
  attr_accessor :scraped_at
  def initialize raw, scraped_at
    super raw
    self.scraped_at = scraped_at
  end

  # Public timeline is an array of users with one tweet each
  def healthy?() raw && raw.is_a?(Array) end
  def each &block
    raw.each do |hsh|
      parsed = JsonTweet.new(hsh, nil)
      next unless parsed && parsed.healthy?
      twitter_user = parsed.generate_user_partial
      tweet        = parsed.generate_tweet
      yield twitter_user, tweet
    end
  end
end
