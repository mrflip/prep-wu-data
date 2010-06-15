#!/usr/bin/env ruby
# require 'rubygems'
# require 'json'
# require 'imw' ; include IMW
# require 'imw/dataset/datamapper'
# as_dset __FILE__
# require 'fileutils'; include FileUtils


# ===========================================================================
# #
# # Setup database
# #
DB_NAME = 'imw_twitter_graph'
# DataMapper.logging = true
# dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => DB_NAME })
# DataMapper.setup_remote_connection dbparams

# ===========================================================================
#
# Bulk insert requests from the user_partials table
#
#

def set_table_count table, var, cond
  puts %Q{ SELECT count(*) INTO @#{var} FROM `#{ table }` tc  WHERE (#{cond}) ; }
end

def histogram_with_non_zeros table, field, limit=300
  set_table_count table, 'zero_count', "#{field} = 0"
  puts %Q{
    SELECT "Histogram for #{field}" AS query_name \\G
    SELECT raw.bin, raw.num,
      TO_PERCENT(raw.num / @total_count) AS bin_pct,
                  SUM(running.num)                     AS running_total,
      TO_PERCENT( SUM(running.num) / @total_count)     AS running_pct,
                  SUM(running.num) - @zero_count       AS nz_running_total,
      TO_PERCENT((SUM(running.num) - @zero_count) /
                         (@total_count - @zero_count)) AS nz_running_pct
    FROM ( SELECT #{field} as bin, count(*) as num FROM #{ table } t GROUP BY bin ) raw,
         ( SELECT #{field} as bin, count(*) as num FROM #{ table } t GROUP BY bin ) running
    WHERE running.bin <= raw.bin
    GROUP BY raw.bin
    LIMIT #{limit}
    ;
  }
end

def coarsen field, binsize
 "(#{binsize} * CEILING( #{field} / #{binsize} ))"
end

puts "use #{DB_NAME}"
table = 'twitter_user_profiles'
set_table_count table, 'total_count', 1
[
  # 'length(name)',
  # 'length(url)',
  # 'length(location)',
  # 'length(description)',
  # 'length(time_zone)',
].each do |field|
  histogram_with_non_zeros table, field
end

table = 'twitter_users'
set_table_count table, 'total_count', 1
histogram_with_non_zeros table, 'length(screen_name)'

table = 'twitter_user_styles'
set_table_count table, 'total_count', 1
histogram_with_non_zeros table, 'length(profile_image_url)'
histogram_with_non_zeros table, 'length(profile_background_image_url)'


table = 'tweets'
set_table_count table, 'total_count', 1
[
  'length(text)',
  'length(fromsource)',
  'length(fromsource_url)',
].each do |field|
  histogram_with_non_zeros table, field
end


table = 'tweet_urls'
set_table_count table, 'total_count', 1
histogram_with_non_zeros table, 'length(tweet_url)'

table = 'hashtags'
set_table_count table, 'total_count', 1
histogram_with_non_zeros table, 'hashtag'
