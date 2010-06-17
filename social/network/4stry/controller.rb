#!/usr/bin/env ruby
require 'rubygems'
require 'imw'


#
# Basically, one giant conditional logic nightmare ...
#
def make_client_pics client
  client_dir = IMW.open("input/#{client}")
  client_dir.contents.each do |accounts_or_terms|
    task_dir = IMW.open(accounts_or_terms)
    make_pics_from_dir task_dir
  end
end

#
# Takes either "seach_terms" or "handles" directory and makes vizs
#
def make_pics_from_dir data_dir
  data_dir.contents.each do |path|
    one_query_pics path
  end
end

#
# Takes a single search term or user handle and makes all its necessary vizs
#
def one_query_pics path
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
def events events_dir
  puts "making event visualizations from #{events_dir.path}..."
  events_dir.contents.each do |data|
    file = IMW.open(data)
    case file.basename
    when "at_mentions.tsv","mentions.tsv" then
      mentions file
    when "at_replies.tsv" then
      replies file
    when "retweets.tsv" then
      retweets file
    end
  end
end


#
# Everything below should be specialized and shell out to the appropriate viz tool
#


def geo_heatmap user_data
  puts "making geo heatmap from #{user_data.basename}..."
end

def wordbag wordbag_data
  puts "making wordcloud from #{wordbag_data.basename}..."
end

def replies replies_data
  puts "making replies plot from #{replies_data.basename}..."
end

def retweets retweets_data
  puts "making retweets plot from #{retweets_data.basename}..."
end


def mentions mentions_data
  puts "making mentions plot from #{mentions_data.basename}..."
end




#
# Expected that data is a tab separated, two column, file with the first row containing titles
#
# Please don't cry.
#
def R_timeseries data
  r_script = File.open("timeseries.r", 'wb')
  r_script << "d <- read.table('#{data}', header=T)\n"
  r_script << "pdf(file='#{data}.pdf')\n"
  r_script << "plot(d)"
  r_script.close
  %x{R --slave < 'timeseries.r'}
end

