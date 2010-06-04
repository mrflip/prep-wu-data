#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'wuclan/twitter'; include Wuclan::Twitter::Model

#
# We want to record each individual state of the resource, with the last-seen of
# its timestamps (if there are many). So if we saw
#
#     rsrc  id   screen_name   followers_count  friends_count  (...) scraped_at
#     user  23   skidoo        47               61                   20090608
#     user  23   skidoo        48               62                   20090802
#     user  23   skidoo        48               62                   20090901
#     user  23   skidoo        52               62                   20090920
#     user  23   skidoo        52               62                   20090922
#     user  23   skidoo        52               63                   20090923
#
# we would only keep
#
#     user  23   skidoo        47               61                   20090608
#     user  23   skidoo        48               62                   20090802
#     user  23   skidoo        52               62                   20090920
#     user  23   skidoo        52               63                   20090922
#
class LastSeenStateUniqer < Wukong::Streamer::UniqByLastReducer
  include Wukong::Streamer::StructRecordizer
  attr_accessor :uniquer_count

  #
  # FIXME -- move this into the models themselves.
  #
  # for immutable objects we can just work off their ID.
  #
  # for mutable objects we want to record each unique state: all the fields
  # apart from the scraped_at timestamp.
  #
  def get_key obj, *_
    case obj
    when Tweet, SearchTweet, DeleteTweet
      obj.id
    when AFavoritesB, AFollowsB, ARepliesBName, ARepliesB, AAtsignsB, AAtsignsBId, ARetweetsB, ARetweetsBId, TwitterUserId
      obj.key
    when TwitterUser, TwitterUserPartial, TwitterUserProfile, TwitterUserSearchId, TwitterUserStyle
      obj.id
    when BadRecord
      obj
    else
      warn "Don't know how to extract key from #{obj.class}"
    end
  end

  #
  # Adopt each value in turn: the last one's the one you want.
  #
  def accumulate obj, *_
    self.final_value = obj
  end

  #
  # Emit the last-seen value
  #
  def finalize
    yield final_value.to_flat(false) if final_value
  end
end

if $0 == __FILE__
  # Go script go!
  Wukong::Script.new(
    nil,
    LastSeenStateUniqer,
    :partition_fields => 2,
    :sort_fields      => 3
    ).run
end
