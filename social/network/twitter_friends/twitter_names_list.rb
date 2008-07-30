#!/usr/bin/env ruby

require "rubygems"
require "YAML"

POOL=File.dirname(__FILE__)
FIXD=POOL+'/fixd'
RIPD=POOL+'/ripd'

def following_filename twitter_name
  FIXD + "/following/#{twitter_name}"
end

TWITTER_NAME_RE = %r{^ +<a href="http://twitter.com/([^"]+)" class="url" rel="contact"} #"
def extract_following(twitter_name, user_html_file)
  puts "\t...finding followers of #{twitter_name}"
  File.open(following_filename(twitter_name), "w") do |following_file|
    File.open(user_html_file).readlines.each do |line|
      if line =~ TWITTER_NAME_RE
        following_file << "#{$1}\n"
      end
    end
  end
end



twitter_names = { }
Dir["#{RIPD}/twitter.com/*"].each do |f|
  twitter_name = File.basename(f)
  unless File.exist? following_filename(twitter_name)
    print "%-20s" % [twitter_name]
    extract_following(twitter_name, f)
  end
  File.open(following_filename(twitter_name)).readlines.each do |followed|
    followed.chomp!
    twitter_names[followed] ||= 0
    twitter_names[followed]  += 1
  end
end
twitter_names = twitter_names.sort_by{ |twitter_name, n| -n }

outfile = "#{FIXD}/stats/twitter_names.yaml"
YAML.dump({ :names => twitter_names }, File.open(outfile, "w"))

# File.open(, "w") do |out_file|
#   twitter_names.sort_by{ |twitter_name, n| n }.each do |twitter_name, n|
#     out_file << "%7d\t%s" % [n, twitter_name]
#   end
# end
# find twitter.com -type f -exec cat {} \; \
#     | ruby -ne '$_ =~  and puts $1' \
#     | sort | uniq -c | sort -rn > twitter_names.txt
