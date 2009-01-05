#!/usr/bin/env ruby

# ===========================================================================
#
# Parse the line
#
def load_line line
  m = %r{^(\w+)\t(\d+)\t(user|followers|friends)\t(\d+)\t([\d\-]{14,15})\t(.*)$}.match(line)
  if !m then warn "Can't grok #{line}"; return [] ; end
  screen_name, twitter_user_id, context, page, scraped_at, json = m.captures
  begin
    raw = JSON.load(json)
  rescue Exception => e
    warn "Couldn't open and parse #{[screen_name, twitter_user_id, context, page, scraped_at].join('-')}: #{e}"
    return []
  end
  [ screen_name, twitter_user_id, context, page, scraped_at, raw ]
end

# ===========================================================================
#
# Suck all the sweet juicy info in each line
#
def parse_keyed_file
  $stdin.each do |line|
    line.chomp! ; next if line.blank?
    file_owner_name, file_owner_id, context, page, scraped_at, raw = load_line(line); next if raw.blank?
    # track_count file_owner_name[0..1].downcase, 100
    case context
    when 'followers', 'friends'
      #
      # A list of followers or friends, each with one tweet and a partial_user
      #
      raw.each do |hsh|
        next if hsh.blank? || (! hsh.is_a?(Hash)) || (hsh['screen_name']=='')
        repair_id(hsh, 'id')
        #
        # Register the follower / friend relationship
        #
        if context == 'followers'
          # follower: this person *follows* the file owner
          AFollowsB.new_from_hash(scraped_at,
            'user_a_id' => hsh['id'],     'user_a_name' => hsh['screen_name'],
            'user_b_id' => file_owner_id, 'user_b_name' => file_owner_name   ).emit
        else
          # friend: this person is *followed by* the file owner.
          AFollowsB.new_from_hash(scraped_at,
            'user_a_id' => file_owner_id, 'user_a_name' => file_owner_name,
            'user_b_id' => hsh['id'],     'user_b_name' => hsh['screen_name'] ).emit
        end
        #
        # Make note of the user
        #
        emit_user hsh, scraped_at, true
        #
        # Grab the tweet
        #
        tweet_hsh  = hsh['status'] or next
        tweet_hsh['twitter_user'   ] = hsh['screen_name']
        emit_tweet tweet_hsh
      end
    when 'user'
      #
      # Make note of the user
      #
      repair_id(raw, 'id')
      emit_user raw, scraped_at, false
    else
      raise "Crap bubbles -- unexpected context #{context}"
    end
  end
end

def parse_flat_tweets
  $stdin.each do |line|
    line.chomp! ; next if line.blank?
    begin
      raw = JSON.load(line)
    rescue Exception => e
      warn "Couldn't open and parse #{line[0..100]}: #{e}"
      next
    end
    #
    # A list of tweets including user
    #
    raw.each do |tweet_hsh|
      next if tweet_hsh.blank? || (! tweet_hsh.is_a?(Hash)) || (tweet_hsh['user'].blank?)
      repair_id(tweet_hsh, 'id')
      user_hsh = tweet_hsh['user']
      next unless user_hsh['screen_name']
      #
      # Make note of the user
      #
      repair_id(user_hsh, 'id')
      scraped_at = repair_date_attr(tweet_hsh, 'created_at')
      emit_user user_hsh, scraped_at, true
      #
      # Grab the tweet
      #
      tweet_hsh['twitter_user'   ] = user_hsh['screen_name']
      tweet_hsh['twitter_user_id'] = user_hsh['id']
      emit_tweet tweet_hsh
    end # tweet
  end # file
end

case ARGV[0]
when '--keyed'    then parse_keyed_file
when '--tweets'   then parse_flat_tweets
else raise "Need to specify an argument: --map, --reduce"
end
