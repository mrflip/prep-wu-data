#!/usr/bin/env ruby

TW_DIR="/data/new/twitter"



def following_filename twitter_id
  TW_DIR + "/following/#{twitter_id}"
end

TWITTER_ID_RE = %r{^ +<a href="http://twitter.com/([^"]+)" class="url" rel="contact"} #"
def extract_following(twitter_id, user_html_file)
  puts "\t...finding followers of #{twitter_id}"
  File.open(following_filename(twitter_id), "w") do |following_file|
    File.open(user_html_file).readlines.each do |line|
      if line =~ TWITTER_ID_RE
        following_file << "#{$1}\n"
      end
    end
  end
end



twitter_ids = { }
Dir["#{TW_DIR}/twitter.com/*"].each do |f|
  twitter_id = File.basename(f)
  unless File.exist? following_filename(twitter_id)
    print "%-20s" % [twitter_id]
    extract_following(twitter_id, f)
  end
  File.open(following_filename(twitter_id)).readlines.each do |followed|
    twitter_ids[followed] ||= 0 
    twitter_ids[followed]  += 1 
  end
end

File.open("#{TW_DIR}/new-twitter_ids.txt", "w") do |out_file|
  twitter_ids.sort_by{ |twitter_id, n| n }.each do |twitter_id, n|
    out_file << "%7d\t%s" % [n, twitter_id]
  end
end

# find twitter.com -type f -exec cat {} \; \
#     | ruby -ne '$_ =~  and puts $1' \
#     | sort | uniq -c | sort -rn > twitter_ids.txt
