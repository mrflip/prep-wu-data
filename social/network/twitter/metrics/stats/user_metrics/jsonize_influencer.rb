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
    [:ms_tw_o,     Integer],
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

  def feedness
    return if (url_o.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    (url_o.to_f / tw_o.to_f).round_to(2)
  end

  def interesting
    return if (at_i.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    ((SAMPLE_CORR_FACTOR*at_i.to_f) / tw_o.to_f).round_to(2)
  end

  def sway
    return if (rt_i.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    ((SAMPLE_CORR_FACTOR*rt_i.to_f) / tw_o.to_f).round_to(2)
  end

  def chattiness
    return if (at_o.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    (at_o.to_f / tw_o.to_f).round_to(2)
  end

  def enthusiasm
    return if (rt_o.blank? || tw_o.blank? || tw_o.to_f == 0.0)
    (rt_o.to_f / tw_o.to_f).round_to(2)
  end

  def influx
    return unless tw_i
    days = days_since_created
    return if (days.blank? || days == 0)
    (tw_i.to_i / days).round_to(2)
  end

  def outflux
    return unless tw_o
    days = days_since_created
    return if (days.blank? || days == 0)
    (tw_o.to_i / days).round_to(2)
  end

  def follow_churn
    return if (fo_o.blank? || followers.blank? || followers.to_f == 0.0 )
    (fo_o.to_f / followers.to_f).round_to(2)
  end

  def follow_rate
    return unless followers
    days = days_since_created
    return if (days.blank? || days == 0)
    (followers.to_i / days).round_to(2)
  end

  def reach
  end

  def reciprocity
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

  def at_trstrank
    return if at_tr.blank?
    at_tr.to_f.round_to(2)
  end

  def fo_trstrank
    return if fo_tr.blank?
    fo_tr.to_f.round_to(2)
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
