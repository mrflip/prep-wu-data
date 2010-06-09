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
set :output, '/data/log/cron.log'

TODAY = Time.now.strftime("%Y%m%d")
namenode = "ec2-204-236-225-16.compute-1.amazonaws.com"

def hostname
  hostname ||= `hostname`.chomp.gsub(".","_")
end


# change permissions of twitter and myspace data
every 1.days, :at => '12:00am' do
  command "sudo chmod -R g+w /data/ripd/com.tw/*"
  command "sudo chmod -R g+w /data/ripd/com.my/*"  
  command "sudo chgrp -R admin /data/ripd/com.tw/*"
  command "sudo chgrp -R admin /data/ripd/com.my/*"
end

# bzip all twitter and myspace data older than 1 day with extensions of xml, json, or tsv
every 1.days, :at => '12:02am' do
  command "find /data/ripd/com.tw/*/2010* -mtime +0 \( -name '*.xml' -o -name '*.json' -o -name '*.tsv' \) -exec bzip2 {} \;"
  command "find /data/ripd/com.my/*/2010* -mtime +0 \( -name '*.xml' -o -name '*.json' -o -name '*.tsv' \) -exec bzip2 {} \;"
end

# pushes twitter data to Amazon S3
every 1.days, :at => '10:00am' do
  command "/home/doncarlo/ics/wuclan/examples/twitter/push_twitter_to_s3.sh"
end

# record the size and number of lines of twitter data scraped that day
every 1.days, :at => '12:00pm' do
  command "/home/doncarlo/ics/wuclan/examples/twitter/scraper_stats.sh", :output => "/data/log/com.tw/#{hostname}-twitter-scraper-stats.log"
end

