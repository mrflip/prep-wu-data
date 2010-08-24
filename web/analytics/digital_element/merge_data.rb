#!/usr/bin/env ruby
require 'rubygems'
require 'wukong'
require 'json'
require 'wukong/periodic_monitor'

Settings.define :dataset,    :required => true, :default => 'ip_geo_census'

# cat ip_geo_census_matched.tsv | ~/ics/icsdata/web/analytics/parse_ipv4_geo_ip_census.rb --map > ip_geo_census_24_blocks.tsv


# -rw-r--r-- 1 flip flip  143101271 2010-08-23 18:26 company.tsv         3294786
# -rw-r--r-- 1 flip flip  583936851 2010-08-23 18:42 domain.tsv          6089998
# -rw-r--r-- 1 flip flip  430647304 2010-08-23 19:21 isp.tsv             8697233
# -rw-r--r-- 1 flip flip  195943021 2010-08-23 19:07 naics.tsv           3785629
# -rw-r--r-- 1 flip flip    6268634 2010-08-23 19:21 proxy.tsv             54524
#
# -rw-r--r-- 1 flip flip 1123263181 2010-08-23 18:48 demographics.tsv    6072359
# -rw-r--r-- 1 flip flip  717619400 2010-08-23 19:27 language.tsv       13219048
#
# -rw-r--r-- 1 flip flip 5865597042 2010-08-23 19:03 geo.tsv            16777216
# -rw-r--r-- 1 flip flip 1481715659 2010-08-23 19:17 zip_area_time.tsv  13208621
#
# export LC_ALL=C
# script_dir=~/ics/icsdata/web/analytics/digital_element
# ( for foo in geo zip_area_time              ; do cat $foo.tsv | $script_dir/merge_data.rb --dataset=$foo --map ; done ) | sort -S4G  > temp_geo.tsv
# ( for foo in domain company isp naics proxy ; do cat $foo.tsv | $script_dir/merge_data.rb --dataset=$foo --map ; done ) | sort -S4G  > temp_domain.tsv
# ( for foo in demographics language          ; do cat $foo.tsv | $script_dir/merge_data.rb --dataset=$foo --map ; done ) | sort -S4G  > temp_demographics.tsv
#
# dataset=demographics ; cat temp_${dataset}.tsv | $script_dir/merge_data.rb --dataset=${dataset} --reduce > merged_${dataset}.tsv

# inject the dataset name into the dataset, needed to properly merge the datasets.
class Mapper < Wukong::Streamer::LineStreamer
  def process line
    key, rest = line.split(/\t/, 2)
    ip24, ip16, ip8 = key.split('.').map{|ip| "%03d"%ip.to_i}
    yield [ip24, ip16, ip8, Settings.dataset, rest]
  end
end

class Reducer < Wukong::Streamer::AccumulatingReducer
  # chunks are held as
  #    24,{...}   48,{...}  255,{...}
  #    last_8,json TAB last_8,json TAB last_8,json
  # we break this out into a list of pairs
  def parse_chunks *chunks
    chunks.map{|chunk| ip0, json = chunk.split(",", 2) ; [ ip0.to_i, JSON.load(json) ] }
  end


  def get_key ip24, ip16, ip8, *args
    [ip24, ip16, ip8].map{|i| i.to_i }.join('.')
  end

  def start! *args
    @ip_block = {}
  end

  def accumulate ip24, ip16, ip8, dataset, *chunks
    @ip_block[dataset] = parse_chunks(*chunks)
  end

  def finalize
    # p @ip_block
    # log.periodically{ print_progress(key, ip_tail_to_json) }

    #
    # First, make a place to receive each merged payload
    #
    merged_chunks = {}
    @ip_block.each do |dataset,chunks|
      chunks.each{|ip0, hsh| merged_chunks[ip0] = {} }
    end
    boundaries = merged_chunks.keys.sort

    #
    # Now take each composite chunk and splice it into each merged_chunk it overlaps
    #
    boundaries.each do |bdy|
      @ip_block.each do |dataset, chunks|
        ip0, hsh = chunks.first
        merged_chunks[bdy].merge! hsh if hsh
        chunks.shift if ip0 == bdy
      end
    end

    output_chunks = merged_chunks.sort.map{|ip0, hsh| "#{ip0},#{hsh.to_json}" }.join("\t")
    yield [ key, output_chunks]
  end

  # track progress --
  def print_progress *args
    Log.info log.progress(db.size, *args)
  end
  # Used to log progress periodically
  def log
    @log ||= PeriodicMonitor.new(options)
  end
end

Wukong::Script.new(Mapper, Reducer).run
