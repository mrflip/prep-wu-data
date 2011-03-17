#!/usr/bin/env ruby

# Reach                   (constant) * [ (tw_o/day)*fo_i + (avg_dir_reach)*(sample_corr_factor * rt_i / tw_o) ]
# Rel Reciprocity         st_i / fo_o                             How many of the people I follow have *strong* links back? (Note: strength of link should prob. be slightly diff for now than for actual strong link call)

require 'rubygems'
require 'wukong'
require 'json'

SAMPLE_CORR_FACTOR = 5.0
Float.class_eval do def round_to(x) ((10**x)*self).round.to_f / (10**x) end ; end

class Influencer < TypedStruct.new(
    [:screen_name, String ],
    [:user_id,     Integer],
    [:created_at,  Bignum ],
    [:followers,   Integer],
    [:friends,     Integer],
    [:fo_o,        Integer],
    [:fo_i,        Integer],
    [:at_o,        Integer],
    [:at_i,        Integer],
    [:re_o,        Integer],
    [:re_i,        Integer],
    [:rt_o,        Integer],
    [:rt_i,        Integer],
    [:tw_o,        Integer],
    [:tw_i,        Integer],
    [:obs_tw_o,     Integer],
    [:hsh_o,       Integer],
    [:sm_o,        Integer],
    [:url_o,       Integer],
    [:at_tr,       Float  ],
    [:fo_tr,       Float  ]
    )

  def days_since_created
    return if created_at.blank?
    (DateTime.now - DateTime.parse(created_at)).to_f
  end

  #
  # How likely is a tweet by this user to contain a url? Should be strictly in
  # (0,1) since both numerator and denominator are measured quantities.
  #
  def feedness
    return if (url_o.blank? || obs_tw_o.blank? || obs_tw_o.to_f == 0.0)
    # We fucked up last time
    # (url_o.to_f / tw_o.to_f).round_to(2)
    (url_o.to_f / obs_tw_o.to_f).round_to(2)
  end

  #
  # How many atsigns does this user recieve for every tweet they send out? This
  # value is strictly positive but not bounded.
  #
  def interesting
    return if (at_i.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    ((SAMPLE_CORR_FACTOR*at_i.to_f) / tw_o.to_f).round_to(2)
  end

  #
  # How many retweets does this user get per tweet they send out? Strictly
  # positive but not bounded.
  #
  def sway
    return if (rt_i.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    ((SAMPLE_CORR_FACTOR*rt_i.to_f) / tw_o.to_f).round_to(2)
  end

  #
  # How likely is it that a tweet by this user contains an atsign of another
  # twitter user? This value should be strictly in (0,1) since it uses measured quantities.
  #
  def chattiness
    return if (at_o.blank? || obs_tw_o.blank? || obs_tw_o.to_f == 0.0)
    # We fucked up last time
    # (at_o.to_f / tw_o.to_f).round_to(2)
    (at_o.to_f / obs_tw_o.to_f).round_to(2)
  end

  #
  # How likely is it that a tweet by this user is a retweet of another twitter
  # user's tweet? This value should be strictly in (0,1) since it uses measured quantities.
  #
  def enthusiasm
    return if (rt_o.blank? || obs_tw_o.blank? || obs_tw_o.to_f == 0.0)
    # We fucked up last time
    # (rt_o.to_f / tw_o.to_f).round_to(2)
    (rt_o.to_f / obs_tw_o.to_f).round_to(2)
  end

  #
  # Approximately how many tweets does this user see per day? This is not
  # directly measured, makes use of API quantities, and is not bounded.
  #
  def influx
    return unless tw_i
    days = days_since_created
    return if (days.blank? || days == 0)
    (tw_i.to_i / days).round_to(2)
  end

  #
  # Approximately how many tweets does this user send out per day? This is not
  # directly measured, makes use of API quantities, and is not bounded.
  #
  def outflux
    return unless tw_o
    days = days_since_created
    return if (days.blank? || days == 0)
    (tw_o.to_i / days).round_to(2)
  end

  #
  # To what extent does this user follow others in the hopes of receiving a
  # 'follow back'? A high value (> 1) gives some indication that the user is
  # following other users then immediately unfollowing them. Uses API quantities
  # and is not bounded.
  #
  def follow_churn
    return if (fo_o.blank? || friends.blank? || friends.to_f == 0.0 )
    # We fucked up last time
    # (fo_o.to_f / followers.to_f).round_to(2)
    (fo_o.to_f / friends.to_f).round_to(2)
  end

  #
  # Approximately how many people does this person follow per day?
  #
  def follow_rate
    return unless friends
    days = days_since_created
    return if (days.blank? || days == 0)
    # We fucked up last time
    # (followers.to_i / days).round_to(2)
    (friends.to_i / days).round_to(2)
  end

  def reach
  end

  def reciprocity
  end

  def at_trstrank
    return if at_tr.blank?
    at_tr.to_f.round_to(2)
  end

  def fo_trstrank
    return if fo_tr.blank?
    fo_tr.to_f.round_to(2)
  end


  def to_hash
    {
      :user_id      => user_id,
      :screen_name  => screen_name,
      :feedness     => feedness,
      :interesting  => interesting,
      :sway         => sway,
      :chattiness   => chattiness,
      :enthusiasm   => enthusiasm,
      :influx       => influx,
      :outflux      => outflux,
      :follow_churn => follow_churn,
      :follow_rate  => follow_rate,
      :reach        => reach,
      :reciprocity  => reciprocity,
      :at_trstrank  => at_trstrank,
      :fo_trstrank  => fo_trstrank
    }.compact_blank!
  end

  def to_json
    self.to_hash.to_json
  end

end

class Mapper < Wukong::Streamer::StructStreamer

  def process user, *_
    yield [user.user_id, user.to_json]
  end

end


Wukong::Script.new(Mapper, nil).run
