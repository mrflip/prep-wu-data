#!/usr/bin/env ruby
require 'rubygems'
require 'imw'

module R_connection
  module ClassMethods
    #
    # Expected that data is a tab separated, two column, file with the first row containing titles
    #
    # Please don't cry.
    #
    def R_timeseries data
      return unless data
      name = IMW.open(data).basename.gsub(/\.tsv/, '').gsub('_', ' ').split(' ').map{|word| word.capitalize}.join(' ')
      return if name =~ /.*\.png/
      r_script = File.open("timeseries.r", 'wb')
      r_script << "d <- read.table('#{data}', header=T)\n"
      r_script << "png(file='#{data}.png', width=640, height=480)\n"
      r_script << "plot(d, col='blue', type='l', main='#{name}', axes=F)\n"
      r_script << "axis(2, tck=0.01)\n"           # y axis
      r_script << "axis(1, tck=0.01)\n"           # x axis
      r_script << "axis(3, tck=0.01, labels=F)\n" # top
      r_script << "axis(4, tck=0.01, labels=F)\n" # bottom
      r_script << "box()"
      r_script.close
      %x{R --slave < 'timeseries.r'}
      IMW.open('timeseries.r').rm 
    end

    def R_geo_heatmap data
      r_script = File.open("geo_heatmap.r", 'wb')
      r_script << "library('maps')\n"
      r_script << "png(file='#{data}.png', width=3200, height=1800)\n"
      r_script << "d <- read.table('#{data}', header=T)\n"
      r_script << "map('world', resolution=0, bg='black', fill=F, col='grey', lwd=1)\n"
      r_script << "map('state', resolution=0, add=T, fill=F, col='grey', lwd=1)\n"      
      r_script << "points(d$latitude, d$longitude, pch='.', cex=4, col='yellow')\n"
      r_script.close
      %x{R --slave < 'geo_heatmap.r'}
      IMW.open('geo_heatmap.r').rm
    end

    #
    # We for sure need the "maps" package
    #
    def install_R_depends
      r_script = File.open("depends.r", 'wb')
      r_script << "install.packages('maps', repos = 'http://cran.r-project.org')\n"
      r_script << "install.packages('mapproj', repos = 'http://cran.r-project.org')\n"      
      r_script.close
      %x{R --slave < 'depends.r'}
      IMW.open('depends.r').rm
    end

    #
    # The contract here is to take a tab separated input file. This file should
    # be of the form:
    #
    # [word, count]
    #
    # I'm fairly certain that R can do wordclouds as well...
    def R_wordcloud data
      puts "whee"
    end
    
  end
  
  def self.included base
    base.class_eval{ extend ClassMethods }
  end
  
end

class Forestry

  include R_connection
  #
  # Basically, one giant conditional logic nightmare ...
  #
  def self.make_client_pics client
    client_dir = IMW.open("input/#{client}")
    client_dir.contents.each do |accounts_or_terms|
      task_dir = IMW.open(accounts_or_terms)
      make_pics_from_dir task_dir
    end
  end

  #
  # Takes either "seach_terms" or "handles" directory and makes vizs
  #
  def self.make_pics_from_dir data_dir
    data_dir.contents.each do |path|
      one_query_pics path
    end
  end

  #
  # Takes a single search term or user handle and makes all its necessary vizs
  #
  def self.one_query_pics path
    query = IMW.open(path)
    query.contents.each do |data|
      file = IMW.open(data)
      case file.basename
      when "events" then
        events file
      when "engaged_users.tsv","users_mentioning.tsv" then
        geo_heatmap file
      when "wordbag.json","aggregate_wordbag.json" then
        wordbag file
      end
    end
  end
  
  #
  # Makes all the vizs for all the data in a particular event directory
  #
  def self.events events_dir
    puts "making event visualizations from #{events_dir.path}..."
    events_dir.contents.each do |data|
      R_timeseries data
    end
  end

  #
  # Can use R's "map" package for this. Need to make sure it's installed
  #
  def self.geo_heatmap user_data
    puts "making geo heatmap from #{user_data.basename}..."
    R_geo_heatmap user_data.path
  end

  #
  # IBM java wordcloud is the best for this
  #
  def self.wordbag wordbag_data
    puts "making wordcloud from #{wordbag_data.basename}..."
    R_wordcloud wordbag_data.path
  end

end

Forestry.make_client_pics "beggars_group"
