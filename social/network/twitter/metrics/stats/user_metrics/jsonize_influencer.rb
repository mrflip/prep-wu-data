#!/usr/bin/env ruby

# Feedness                url_o   / tw_o
# Interesting             sample_corr * obs_at_i / tw_o           When this user tweets, how often others reply?
# Sway                    sample_corr * obs_rt_i / tw_o           When this user tweets, how often is is retweeted?
# Chattiness              obs_at_o / obs_tw_o                     What fraction of tweets mention others?
# Enthusiasm              obs_rt_o / obs_tw_o                     What fraction of tweets rebroadcast anothers'?
# Mention TR              tr_at                                   
# Follower TR             tr_fo                                   
# Outflux est             tw_o / day
# Influx est              tw_i / day
# Follow churn            obs_fo_o / followers_count              Shows them following/unfollowing people (douchiness)
# Follow rate             fo_o / day
# Reach                   (constant) * [ (tw_o/day)*fo_i + (avg_dir_reach)*(sample_corr_factor * rt_i / tw_o) ]
# Rel Reciprocity         st_i / fo_o                             How many of the people I follow have *strong* links back? (Note: strength of link should prob. be slightly diff for now than for actual strong link call)

require 'rubygems'
require 'wukong'
require 'json'


class Influencer < TypedStruct.new(
    [:screen_name, String],
    [:user_id,     Integer],
    [:feedness,    Float],
    [:interesting, Float],
    [:sway,        Float],
    [:chattiness,  Float],
    
class Mapper < Wukong::Streamer::RecordStreamer

  def process sn, uid, fo_o, fo_i, at_o, at_i, re_o, re_i, rt_o, rt_i, tw_o, tw_i, ms_tw_o, hsh_o, sm_o, url_o
    yield [ screen_name, user_id, hsh.to_json ]
  end

  def right_now
    Time.now.strftime("%Y%m%d")
  end

end


Wukong::Script.new(Mapper, nil).run
