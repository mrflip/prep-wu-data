#!/usr/bin/env bash
require 'rubygems'
require 'grackle'
require 'json' ;
require 'tokyo_tyrant' ;
require 'tokyo_tyrant/balancer'
require 'active_support/core_ext/module/delegation'

TT_SERVERS  = ['10.194.101.156', '10.196.73.156', '10.196.75.47', '10.242.217.140',] unless defined?(TT_SERVERS)
TT_DATASETS = {
  :screen_names    => 12002,
  :search_ids      => 12003,
  #
  :user_info    => 14200,
  :wordbag      => 14201,
  :influence    => 14202,
  :trstrank     => 14203,
  :conversation => 14204,
  :strong_links => 14205,
} unless defined?(TT_DATASETS)

class TwUser
  attr_reader :user_id

  delegate(
    :screen_name, :created_at, :protected,
    :statuses_count, :favourites_count, :followers_count, :friends_count, :listed_count,
    :name, :description, :lang, :location, :url, :time_zone, :utc_offset,
    :profile_background_color, :profile_background_image_url, :profile_background_tile, :profile_image_url, :profile_link_color, :profile_sidebar_border_color, :profile_sidebar_fill_color, :profile_text_color, :profile_use_background_image,
    :verified, :follow_request_sent, :following, :geo_enabled, :notifications, :contributors_enabled,
    :to => :user_info)


  def initialize screen_name_or_id
    if screen_name_or_id.to_s =~ /^\d+$/
      @user_id = screen_name_or_id.to_i
    else
      @user_id = self.class.screen_name_to_id(screen_name_or_id)
    end
  end

  def tq()       trstrank_hsh && trstrank_hsh['tq'] ; end
  def trstrank() trstrank_hsh && trstrank_hsh['trstrank'] ; end

  def nbr_ids
    @nbr_ids ||= strong_links_hsh['strong_links'].map(&:first)
  end

  def influencer_hsh
    @influencer_hsh ||= load_from_dataset(:influence)
  end
  def trstrank_hsh
    @trstrank_hsh ||= load_from_dataset(:trstrank)
  end
  def conversation_hsh user_b_id
    @conversation_hsh ||= load_from_dataset(:conversation, "#{self.user_id}:#{user_b_id}")
  end
  def strong_links_hsh
    @strong_links_hsh ||= load_from_dataset(:strong_links)
  end

  def load_from_dataset dataset, key=nil
    key ||= self.user_id
    raw_json = self.class.dbs[dataset][key.to_s] or return
    JSON.load(raw_json) rescue nil
  end

  #
  # Get basic info from Twitter API
  #

  def self.screen_name_to_id screen_name
    id = dbs[:screen_names][screen_name.to_s.downcase]
    id && id.to_i
  end

  def self.from_info user_info
    tw_user = self.new(user_info.id)
    tw_user.instance_variable_set('@user_info', user_info)
    tw_user
  end

  def user_info
    @user_info ||= self.class.gclient.users.show?(@user_info_query)
  end

  def last_tweet
    user_info.status
  end

protected
  def self.gclient
    @gclient ||= Grackle::Client.new(:auth=>{:type=>:basic,:username=>'mrflip',:password=>ENV['TWPASS']})
  end

  def self.dbs()
    @dbs ||= {};
    TT_DATASETS.each do |dataset, port|
      @dbs[dataset] = TokyoTyrant::Balancer::DB.new(TT_SERVERS.map{|s| s+':'+port.to_s })
    end
    @dbs
  end

end

# tokyodbs; gclient ; user_info ||= Hash.new{|h,k| h[k] = {} } ; user_info.keys
# [1554031, 19041500, 15748351, 16134540].each{|user_id| populate_from_db(user_info, user_id) ; populate_nbrs(user_info, user_id) ; p show_nbr_screen_names(user_info, user_id) }

