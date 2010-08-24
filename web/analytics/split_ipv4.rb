#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'extlib'

module Ipv4Splitter

  # Represents an Ipv4 block attached to a record.
  class IpBlock
    
    attr_accessor :bot_ip, :top_ip, :record
    
    def initialize bot_ip, top_ip, record
      set_ip_block(bot_ip, top_ip)
      self.record = record
    end

    def set_ip_block bot_ip, top_ip
      if bot_ip.to_s.include?('.') && top_ip.to_s.include?('.')
        self.bot_ip = numericalize_ip(bot_ip)
        self.top_ip = numericalize_ip(top_ip)
      else
        self.bot_ip, self.top_ip = [bot_ip.to_i, top_ip.to_i]
      end
    end

    def numericalize_ip ip
      sum = 0
      ip.to_s.split('.').reverse.each_with_index do |val, power|
        sum += val.to_i * (256 ** (power.to_i))
      end
      sum
    end

    #
    # Generates ip blocks that lie entirely within a /24 range.
    #
    # yields a series of tuples
    #    [ip_head, bot_ip_tail, top_ip_tail]
    # ip_head is the first three octets in a ip/24 block
    # the block starts at bot_ip_0 and ends at top_ip_0 (inclusive)
    #
    def ip_24_blocks
      bot_head, bot_tail = split_ip(bot_ip)
      top_head, top_tail = split_ip(top_ip)

      if bot_head < top_head
        yield [bot_head, bot_tail, 255]
        bot_head += 1
        bot_tail  = 0
      end
      (bot_head ... top_head).each do |seg|
        yield [seg, 0, 255]
      end
      yield [top_head, bot_tail, top_tail]
    end

    def split_ip ip
      ip_head = ip / 2**8
      ip_tail = ip % 2**8
      [ip_head, ip_tail]
    end
  end

  class Mapper < Wukong::Streamer::LineStreamer
    def process line, &blk
      fields = line.chomp.split("\t") rescue []
      ip_bot, ip_top, record = fields
      ip_block = IpBlock.new(ip_bot, ip_top, record)
      ip_block.ip_24_blocks do |ip_head, bot_tail, top_tail|
        dotted_24 = [ip_head >> 16, (ip_head >> 8) % 256, ip_head % 256].join('.')
        yield [dotted_24, "%03d" % top_tail, ip_block.record]
      end
    end
  end

  class Reducer < Wukong::Streamer::AccumulatingReducer
    def get_key ip_24, *args
      ip_24
    end

    def start! ip_24, *args
      @records = []
    end

    def accumulate ip_24, ip_tail_top, json
      @records << [ip_tail_top.to_i, json]
    end

    def finalize
      ip_tail_to_json = @records.sort.map{|ip_tail, json| [ip_tail, json].join(",")}
      yield [ key, ip_tail_to_json ]
    end

  end

  class Script < Wukong::Script
    def local_mode_sort_commandline
      'cat'
    end
  end
  
end



Ipv4Splitter::Script.new(Ipv4Splitter::Mapper, Ipv4Splitter::Reducer).run
