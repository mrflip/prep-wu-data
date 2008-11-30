#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
require 'imw/tracker'
require 'imw/transform'
require 'twitter_profile_model'
as_dset __FILE__

# #
# # Setup database
# #
# DataMapper.logging = true
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams

#
# Transform User
#
def parse_user user_hsh
  user_hsh['protected'] = user_hsh['protected'] ? 1 : 0
  user_hsh
end

#
# Transform tweet
#
require 'twitter_autourl'
$atsigns_transformer   = RegexpRepeatedTransformer.new('text', RE_ATSIGNS)
$hashtags_transformer  = RegexpRepeatedTransformer.new('text', RE_HASHTAGS)
$tweeturls_transformer = RegexpRepeatedTransformer.new('text', RE_URL)
def parse_tweet tweet_hsh
  tweet_hsh['all_atsigns']             = $atsigns_transformer.transform(  tweet_hsh).to_json
  tweet_hsh['all_hash_tags']           = $hashtags_transformer.transform( tweet_hsh).to_json
  tweet_hsh['all_tweeted_urls']        = $tweeturls_transformer.transform(tweet_hsh).to_json
  fromsource_raw = tweet_hsh['source']
  if ! fromsource_raw.blank?
    if m = %r{<a href="([^\"]+)">([^<]+)</a>}.match(fromsource_raw)
      tweet_hsh['fromsource_url'], tweet_hsh['fromsource'] = m.captures
    else
      tweet_hsh['fromsource'] = fromsource_raw
    end
  end
  tweet_hsh['created_at']  = DateTime.parse(tweet_hsh['created_at']) if tweet_hsh['created_at']
  tweet_hsh['favorited'] = tweet_hsh['favorited'] ? 1 : 0
  tweet_hsh['truncated'] = tweet_hsh['truncated'] ? 1 : 0
  tweet_hsh['tweet_len'] = tweet_hsh['text'].length
  #                                         emit_relationship :arepliedb, tweet_hsh['twitter_user_id'].native_id, tweet_hsh['in_reply_to_user_id'], tweet_hsh['id'] if tweet_hsh['in_reply_to_user_id']
  #                                         emit_relationship :arepliedb, tweet_hsh['twitter_user_id'].native_id, tweet_hsh['favorited'],           tweet_hsh['id'] if
  # tweet_hsh['all_atsigns'     ].each{|at| emit_relationship :arepliedb, tweet_hsh['twitter_user_id'].native_id, at, tweet_hsh['id'] }
  # tweet_hsh['all_tweeted_urls'].each{|at| emit_relationship :url,       tweet_hsh['twitter_user_id'].native_id, nil, tweet_hsh['id'], digest(at) }
  # tweet_hsh['all_hash_tags'   ].each{|at| emit_relationship :hashtag,   tweet_hsh['twitter_user_id'].native_id, nil, tweet_hsh['id'], digest(at) }
  tweet_hsh
end

#
# Field order for dump files
#
FIELDS = {
  :users        => %w[  id        followers_count protected screen_name name url description location profile_image_url],
  :friendships  => %w[  friend_id follower_id],
  :tweets       => %w[  id        created_at              twitter_user_id       text
    favorited             truncated               tweet_len
    in_reply_to_user_id   in_reply_to_status_id   fromsource        fromsource_url
    all_atsigns           all_hash_tags           all_tweeted_urls ]
}

#
# parse each file
#
def parse_twitter_followers twitter_user, ripd_file, dump_files
  begin
    raw_followers = JSON.load(File.open(ripd_file))
  rescue Exception => e
    warn "Couldn't open and parse #{ripd_file}: #{e}"
    return false
  end
  raw_followers.each do |follower_hsh|
    parse_user follower_hsh
    #
    dump_files[:users]       << follower_hsh.values_at(*FIELDS[:users])
    #
    dump_files[:friendships] << [twitter_user.native_id, follower_hsh['id']]
    # emit_relationship :afollowsb, twitter_user.native_id, follower_hsh['id']
    #
    tweet_hsh  = follower_hsh.delete('status') or next
    tweet_hsh['twitter_user_id'] = follower_hsh['id']
    parse_tweet(tweet_hsh) or next
    dump_files[:tweets]      << tweet_hsh.values_at(*FIELDS[:tweets]) if tweet_hsh
  end
  true
end

# afollowsb     time  1 0 0 0 0 0 0   user_a_id       user_b_id
# afavoredb     time  0 1 0 0 0 0 0   user_a_id       user_b_id
# arepliedb     time  0 0 1 0 0 0 0   user_a_id       user_b_id       status_id
# aatsigndb     time  0 0 0 1 0 0 0   user_a_id       user_b_id       status_id
#
# hashtag       time  0 0 0 0 1 0 0   user_a_id                       status_id       sha1(hashtag)
# url           time  0 0 0 0 0 1 0   user_a_id                       status_id       sha1(url)
# word          time  0 0 0 0 0 0 1   user_a_id                                       sha1(word)
def emit_relationship relationship
end


#
# Do it
#
#
class FFParserTracker < SerialPriorityTracker
  attr_accessor :dump_files

  # Output File
  def dump_filename(context, resource, batch)
    "fixd/#{context}/#{[resource, batch].compact.join('-')}.tsv"
  end

  #
  # Get a different dump file for each chunk
  def open_dump_files context, chunk_idx
    datetime = Time.now.strftime('%Y%m%d-%H%M%S')
    batch = "%06d-%s" % [chunk_idx, datetime]
    dump_files = {}
    [ :users, :tweets, :friendships ].each do |resource|
      filename = dump_filename(context, resource, batch)
      dump_files[resource] = FasterCSV.open(filename, "w", :col_sep => "\t", :headers => FIELDS[resource], :write_headers => true)
    end
    self.dump_files = dump_files
  end
  def close_dump_files() dump_files.values.each{|f| f.close } end

  #
  #
  def process_chunk chunk_idx, &block
    open_dump_files context, chunk_idx
    super chunk_idx, &block
    close_dump_files
  end

  #
  #
  def process
    each do |req|
      track_count(:user, 10) ; $stderr.print "%d-%-18s"%[req.priority, req.twitter_name]
      # load user
      twitter_user = TwitterUser.first( :twitter_name => req.twitter_name, :fields => [:id, :twitter_name, :native_id] ) or next
      # do it
      begin
        success = parse_twitter_followers twitter_user, '/data/ripd/'+req.ripd_file, dump_files
      rescue Exception => e
        warn e
        false
      end
    end
  end

end

tracker = FFParserTracker.new AssetRequest, :flwr_parse, 200,
  :query_options => { :fields => [:id, :twitter_name, :page], }  # , :dry_run => true, :max_chunk => 1, :offset => 0,
tracker.process

#  :priority.gt => 10000, :priority.lt => 10010

# LOAD DATA INFILE '/tmp/foo' IGNORE
#   INTO TABLE `foo`
#   FIELDS TERMINATED BY '\t' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\'
#   LINES  TERMINATED BY '\n'
#   IGNORE 1 LINES
#   (id, created_at, twitter_user_id, text, favorited, truncated, tweet_len,
#    in_reply_to_user_id, in_reply_to_status_id, fromsource, fromsource_url,
#    all_atsigns, all_hash_tags, all_tweeted_urls)
#
# {
#   "id"                    :935031,
#   "screen_name"           :"killsapo",
#   "followers_count"       :102,
#   "protected"             :false,
#   "name"                  :"SAPO!!",
#   "url"                   :"http:\/\/helo.it\/killsapo\/volume3\/",
#   "description"           :"credo in un solo niente onnipotente. twitter sta a me come i tatuaggi stanno al tipo di Memento.",
#   "location"              :"Saronno. Or Milano thereabouts",
#   "profile_image_url"     :"http:\/\/s3.amazonaws.com\/twitter_production\/profile_images\/27176662\/avatar_flickr_02_27111890_N00_copy_normal.png",
#
#   "status"                :{,
#     "id"                    :1026385640,
#     "created_at"            :"Thu Nov 27 14:07:47 +0000 2008",
#     "in_reply_to_user_id"   :null,
#     "in_reply_to_status_id" :null,
#     "favorited"             :false,
#     "truncated"             :false,
#     "source"                :"<a href=\"http:\/\/iconfactory.com\/software\/twitterrific\">twitterrific<\/a>",
#     "text"                  :"e, comunque, da quando bombay \u00e8 diventata mumbai? mai che qualcuno avvisi me o manuel agnelli."
#   },
# }]


