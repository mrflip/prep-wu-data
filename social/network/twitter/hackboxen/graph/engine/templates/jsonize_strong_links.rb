#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args, &blk
    uid, sn, bag_of_links = args
    yield [uid, 'base', 'strong_links_json', jsonize(uid, sn, bag_of_links)]
  end

  def jsonize uid, sn, bag_of_links
    links        = pig_bag_to_nested_array(bag_of_links)
    # can't be friends with myself, to_i everything
    links.map{|link| link[0] = link[0].to_i; link[1] = link[1].to_f; link }.reject!{|x| x.first == uid.to_i}
    # strong_links = links.inject([]){|a, sub_arr| a << {:user_id => sub_arr.first, :weight => sub_arr.last}} unless links.blank?
    record = { :user_id => uid.to_i, :screen_name => sn, :strong_links => links }.compact_blank.to_json
  end

  def pig_bag_to_nested_array tuple
    tuple.split("),(").map{|t| t.gsub(/[\(\{\}\)]/, '').split(",")} rescue nil # psh
  end
end

Wukong::Script.new(Mapper, nil).run
