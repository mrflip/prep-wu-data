#!/usr/bin/env ruby

# Outflux est             tw_o / day
# Influx est              tw_i / day
# Follow churn            obs_fo_o / followers_count              Shows them following/unfollowing people (douchiness)
# Follow rate             fo_o / day
# Reach                   (constant) * [ (tw_o/day)*fo_i + (avg_dir_reach)*(sample_corr_factor * rt_i / tw_o) ]
# Rel Reciprocity         st_i / fo_o                             How many of the people I follow have *strong* links back? (Note: strength of link should prob. be slightly diff for now than for actual strong link call)

require 'rubygems'
require 'wukong'
require 'json'

SAMPLE_CORR_FACTOR = 5.0

class Influencer < TypedStruct.new(
    [:screen_name, String ],
    [:user_id,     Integer],
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
    right_now - 
  end

  def right_now
    Time.now.strftime("%Y%m%d")
  end
  
  def feedness
    return if (url_o.blank? || tw_o.blank?)
    url_o.to_f / tw_o.to_f
  end

  def interesting
    return if (at_i.blank? || tw_o.blank?)
    (SAMPLE_CORR_FACTOR*at_i.to_f / tw_o.fo_f)
  end

  def sway
    return if (rt_i.blank? || tw_o.blank?)
    (SAMPLE_CORR_FACTOR*rt_i.to_f / tw_o.fo_f)
  end

  def chattiness
    return if (at_o.blank? || tw_o.blank?)
    at_o.to_f / tw_o.to_f
  end

  def enthusiasm
    return if (rt_o.blank? || tw_o.blank?)
    rt_o.to_f / tw_o.to_f
  end

  def influx
  end

  def outflux
  end

  def follow_churn
  end

  def follow_rate
  end

  def reach
  end

  def reciprocity
  end
        
  
end

class Mapper < Wukong::Streamer::StructStreamer

  def process user, *_
    yield [ screen_name, user_id, hsh.to_json ]
  end

  

end


Wukong::Script.new(Mapper, nil).run
