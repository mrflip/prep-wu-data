#!/usr/bin/env ruby

require 'rubygems'
require 'wukong'
require 'json'

class Mapper < Wukong::Streamer::RecordStreamer
  def process *args, &blk
    uid, sn, bag_of_links = args
    yield [uid, jsonize(uid, sn, bag_of_links)]
  end

  def jsonize uid, sn, bag_of_links
    links        = pig_bag_to_nested_array(bag_of_links)
    strong_links = links.inject([]){|a, sub_arr| a << {:user_id => sub_arr.first, :weight => sub_arr.last}} unless links.blank?
    record = { :user_id => uid, :screen_name => sn, :strong_links => strong_links }.compact_blank.to_json
  end

  def pig_bag_to_nested_array tuple
    tuple.split("),(").map{|t| t.gsub(/[\(\{\}\)]/, '').split(",")} rescue nil # psh
  end
end

Wukong::Script.new(Mapper, nil).run
