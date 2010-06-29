# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# adds ">> /path/to/file.log 2>&1" to all commands
# set :output, '/data/log/cron.log'

cron_log = '/data/log/cron.log'

def hostname
  hostname ||= `hostname`.chomp.gsub(".","_")
end


# change permissions of twitter and myspace data
every 1.days, :at => '12:00am' do
  command "sudo chmod -R g+w /data/ripd/com.tw/*", :output => cron_log
  command "sudo chmod -R g+w /data/ripd/com.my/*", :output => cron_log
  command "sudo chgrp -R admin /data/ripd/com.tw/*", :output => cron_log
  command "sudo chgrp -R admin /data/ripd/com.my/*", :output => cron_log
end

# Parse scraped data from the previous day and bzip it.
# This should be run after noon since the stream scraper rotates files every 12 hours and we want to parse yesterday's data.
# The resulting file will be uploaded with the raw data in the script that pushes everything to Amazon S3 below.
every 1.days, :at => '1:00pm' do
  command "/home/doncarlo/ics/infochimp-data/scaffolds/whenever-tasks/parse_scraped_data.sh"
end

# bzip all twitter and myspace data older than 1 day with extensions of xml, json, or tsv
# The raw Twitter data from more than 1 day ago should have been parsed already so it can be bzipped and later sent to S3.
every 1.days, :at => '12:02am' do
  command "find /data/ripd/com.tw/*/2010* -mtime +0 \\( -name '*.xml' -o -name '*.json' -o -name '*.tsv' \\) -exec bzip2 {} \\;", :output => cron_log
  command "find /data/ripd/com.my/*/2010* -mtime +0 \\( -name '*.xml' -o -name '*.json' -o -name '*.tsv' \\) -exec bzip2 {} \\;", :output => cron_log
end

# backs up cluster namenode metadata for the hdfs.  needs to be run on a machine in the same security group as the namenode (cluster master)
# uncomment for running on a computer in the correct security group
# every 1.days, :at => '3:00am' do
#   command "/home/doncarlo/ics/infochimps-data/scaffolds/whenever-tasks/namenode_metadata_bkup.sh", :output => "/data/log/namenode-bkup.log"
# end

# pushes twitter data to Amazon S3
# log file defined in script rather than here (in cron)
every 1.days, :at => '10:00am' do
  command "/home/doncarlo/ics/wuclan/examples/twitter/push_twitter_to_s3.sh" 
end

# pushes myspace data to Amazon S3
# log file defined in script rather than here (in cron)
# every 1.days, :at => '10:30am' do
#   command "/home/doncarlo/ics/wuclan/examples/myspace/push_myspace_to_s3.sh"
# end

# record the size and number of lines of twitter data scraped that day
every 1.days, :at => '12:00pm' do
  command "/home/doncarlo/ics/wuclan/examples/twitter/scraper_stats.rb", :output => {:standard => "/data/log/com.tw/#{hostname}-twitter-scraper-stats.tsv"}
end

