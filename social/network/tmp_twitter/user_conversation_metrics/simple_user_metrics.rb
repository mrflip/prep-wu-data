#!/usr/bin/env ruby
require 'extlib/class'
require 'wukong'                       ; include Wukong
require 'wuclan/twitter'               ; include Wuclan::Twitter::Model
$: << File.dirname(__FILE__)
require 'user_metrics_model'
require 'rubygems'; require 'json'
#
#                user_id  friends followers repl_out  repl_in  ats_out ats_in  rts_out rts_in  favs_out favs_in
# u jack               12     368     26050      103     1144      199   1871        1      32      470    1026
# u scobelizer      13348   62467     63930     2818    20486     3864  21713       25    305        14    7581
# u mrflip        1554031     287       251      265      188      391    224        3      6        24       6
# u random800k    867....     203       221       38      41        46      34                              286
# u random18M    18......       1         2
#

USER_METRICS_BY_SOURCE = {
  :from_user => [
    # :age,                    #           Days between creation and now.
    # :duration,               #   x       Days between last scrape and creation
    # :age_user_scrape,        #   x       How long since your user record was scraped
    :created_on,
    :nbhd_bal,                 #           Friends - follower Balance
    :nbhd_size,                #           Friends - follower nbhd size
    :fo_week,                  #   x       Followers accumulated / week
    :fr_week,                  #   x       Friends   accumulated / week
    :tw_day,                   #   x       Tweets    sent / day
    :fv_mo,                    #   x       Favorites accumulated / day
    :reach,                    #   x       Reach:   (your msgs/day) * |n1|
  ],
  :other => [
    :tw_sampled,               #         t How many tweets have we sampled
  ],
  :from_graph_metrics => [
    :fr_sampled,               #     c     How many friend have we sampled
    :fo_sampled,               #     c     How many followers have we sampled
    :at_out_sampled,           #       g
    :at_in_sampled,            #       g   Atsigns sampled
    :rt_out_sampled,           #       g
    :rt_in_sampled,            #       g   Retweets sen
    :fv_out_sampled,           #     c     How many favorites by you of others, sampled
    :fv_in_sampled,            #     c     How many favorites by others of you, sampled
    :at_in_with,               #       g   Users Atsigning you
    :at_out_with,              #       g
    :rt_in_with,               #       g   Users Retweeting you
    :rt_out_with,              #       g
    :fv_in_with,               #       g   Favorites by others of your tweets, with
    :fv_out_with,              #     c     Number of users who Favorited you
  ],
  # :from_coverage => [
  #   :scrape_age_fo,          #     c     How long since your followers graph record was scraped
  #   :scrape_age_fr,          #     c     How long since your friends graph record was scraped
  #   :scrape_age_fv,          #     c     How long since your friends graph record was scraped
  #   ],
  :from_tweet_metrics => [
    :tw_sampled,               #     c     How many tweets have we sampled
    :tw_recent,                #     c     How many tweets have we sampled in 2009
    :last_tw_at,               #     c     Age of last tweet vs. scraped_
  ],
  :from_graph_simple => [      #
    :last_tw_age,              #   x       How long since your last tweet to now
    :tw_day_recent,            #           Tweets per day (sampled) since 12/08
    #
    # :fo_coverage,            #     c     Followers sampled   / known to exist
    # :fr_coverage,            #     c     Friends sampled / known to exist
    # :fv_coverage,            #     c     Favorites sampled / known to exist
    # :tw_coverage,            #     c     Favorites sampled / known to exist
    #
    #
    :at_tw_out,                #       g   Atsigns sampled per tweet sampled
    :rt_tw_out,                #       g   Retweets sampled per tweet sampled
    :rt_at_out,                #       g   Retweets sampled per atsign sampled
    :at_in_tw_out,             #       g   Atsigns  in  per tweet out
    :rt_in_tw_out,             #       g   Retweets in  per tweet out
    :rt_at_in,                 #       g
  ],
  :from_graph_complicated => [ #
    :n1o_strong,               #       g2  Strong links out
    :n1i_strong,               #       g2  Strong links in
    :cluster_coeff             #       g2  Strong links between members of n1
  ],
}


module GenUserMetrics
  class Mapper < Wukong::Streamer::StructStreamer
    #
    # Take all the component metrics and pass them along to the reducer, using
    # the twitter_user_id as the reduce key
    #
    def process thing, *_
      case thing
      when TwitterUser, TwitterUserPartial
        # , UserGraphMetrics, UserTweetMetrics, UserHashtagMetrics, UserTweetUrlMetrics # , UserScrapingMetrics
        yield ["%010d"%thing.id.to_i]+thing.to_flat
      end
    end
  end

  #
  #
  class Reducer < Wukong::Streamer::AccumulatingReducer
    attr_accessor :user_metrics, :user_partial_record, :user_record
    def recordize line
      id, *rest = line.split("\t")
      Wukong::Streamer::StructRecordizer.recordize *rest
    end
    def get_key thing, *_
      "%010d"%thing.id.to_i
    end
    def start! *args
      self.user_partial_record = nil
      self.user_record         = nil
      self.user_metrics        = UserMetrics.new
    end
    #
    #
    #
    def accumulate thing, *_
      case thing
      when TwitterUserPartial
        self.user_partial_record = thing
        user_metrics.part_scraped_at = DateTime.parse_safely(thing.scraped_at)
      when TwitterUser
        self.user_record         = thing
      when UserGraphMetrics
        user_metrics.adopt_graph_metrics    thing
      when UserTweetMetrics, UserHashtagMetrics, UserTweetUrlMetrics
        user_metrics.adopt_tweet_metrics    thing
      when UserScrapingMetrics
        user_metrics.adopt_scraping_metrics thing
      end
    end

    def finalize
      if user_record
        user_metrics.adopt_user user_record
      end
      if user_partial_record &&
          ( (! user_record) ||
            (user_partial_record.scraped_at.to_i > user_record.scraped_at.to_i) )
        user_metrics.adopt_user_partial user_partial_record
      end
      # return if     (user_metrics.id.to_i == 0)
      # return unless (user_metrics.screen_name =~ /\A\w+\z/)
      [:from_user, :from_graph_simple].each do |seg|
        USER_METRICS_BY_SOURCE[seg].each do |metric|
          user_metrics.send("get_#{metric}")
        end
      end
      user_metrics.fix!
      yield self.user_metrics.to_hash.to_json
    end
  end

  Script.new(
    Mapper,
    Reducer,
    :partition_fields => 1,
    :sort_fields      => 4
    ).run
end

