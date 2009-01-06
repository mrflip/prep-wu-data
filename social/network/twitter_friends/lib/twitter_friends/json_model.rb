require 'rubygems'; require 'json'
require 'hadoop/utils' ; include Hadoop
require 'twitter_friends/twitter_user'
require 'twitter_friends/tweet'
require 'twitter_friends/twitter_model_common'

module JsonParser
  attr_accessor :hsh
  def initialize hsh
    self.hsh = hsh
    self.fix_hsh!
  end

  #
  # Coerce any fields that need fixin'
  #
  def fix_hsh!
  end

  #
  # Safely parse the json object and instantiate with the raw hash
  #
  def self.new_from_json json_str, *args
    begin
      hsh = JSON.load(json_str) or return
    rescue Exception => e; return ; end
    self.new hsh, *args
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
module JsonUser < JsonParser
  def initialize hsh, scraped_at
    super hsh
    self.hsh['scraped_at'] = scraped_at
  end

  # user id from the raw hash
  def twitter_user_id
    hsh['twitter_user_id']
  end

  # ===========================================================================
  #
  # Make the data easier for batch flat-record processing
  #
  def fix_hsh!
    hsh['created_at'] = TwitterModelCommon.flatten_date(hsh['created_at'])
    hsh['id']         = TwitterModelCommon.zeropad_id(hsh['id'])
    hsh['protected']  = TwitterModelCommon.unbooleanize(hsh['protected'])
    scrub_hash hsh, :name, :location, :description, :url
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
    klasses.map do |klass|
      klass.from_hash(hsh)
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
  def generate_last_tweet
    tweet_hsh = hsh['status']
    return unless tweet_hsh && tweet_hsh.is_a?(Hash)
    JsonTweet.new(tweet_hsh, twitter_user_id).generate_tweet
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
module JsonTweet
  # ===========================================================================
  #
  # Make the data easier for batch flat-record processing
  #
  def self.fix_hsh!
    hsh['id']         = TwitterModelCommon.zeropad_id(  hsh['id'])
    hsh['created_at'] = TwitterModelCommon.flatten_date(hsh['created_at'])
    hsh['favorited']  = TwitterModelCommon.unbooleanize(hsh['favorited'])
    hsh['truncated']  = TwitterModelCommon.unbooleanize(hsh['truncated'])
    scrub_hash hsh, :text
  end

  def initialize hsh, scraped_at
    super hsh
    hsh['twitter_user_id'] = twitter_user_id
  end

  def generate_tweet
    Tweet.from_hash(hsh)
  end
end
