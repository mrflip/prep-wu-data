#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'imw' ; include IMW
require 'imw/extract/html_parser'
require 'imw/dataset/datamapper'
require 'twitter_profile_model'
as_dset __FILE__

# #
# # Setup database
# #

# DataMapper.logging = true
dbparams = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_twitter_friends' })
DataMapper.setup_remote_connection dbparams

# matches color defs in the user style's css snippets
COLOR_RE = 'color\:\s*.([\da-f]+)'

class TwitterHTMLParser < HTMLParser
  def self.parser_spec
    sidebar_selector = 'body/div#container/div#side_base/div#side'
    status_box       = 'body/div#container/div#content/div.wrapper'
    {
      :native_id              => to_num('', href('head/link[@href*=".rss"]', %r{.*user_timeline/(\d+)\.rss.*})),
      :profile_img_url        => src("#{status_box}/h2.thumb/a/img#profile-image"),
      :profile                => one("#{sidebar_selector}/div.section/address/ul.entry-author",
        :real_name              => 'li/span.fn',
        :location               => 'li/span.adr',
        :web                    => href('li/a.url'),
        :bio                    => 'li/span.bio'
        ),
      :stats                  => one("#{sidebar_selector}/div.section/ul.stats", {
          :following_count      => to_num('li/span#following_count'),
          :followers_count      => to_num('li/span#followers_count'),
          :favorites_count      => to_num('li/span#favourites_count'),  # note 'u'
          :updates_count        => to_num('li:last/span')               # cheating by going off the order
        }),
      :style_settings         => one('head/style[@type^=text]', {
          :style_name_color           => /h2.thumb\s+a\s*\{#{COLOR_RE};/si,
          :style_link_color           => /a \{#{COLOR_RE};/si,
          :style_text_color           => /body[^\}\;]*#{COLOR_RE};/si,
          :style_bg_color             => /body[^\}]*?background-#{COLOR_RE}\;/si,
          :style_sidebar_fill_color   => /#side[^\}\;]*background-#{COLOR_RE};/si,
          :style_sidebar_border_color => /#side[^\}\;]*border\:[^;]+#([\da-f]+);/si,
          [:style_bg_color, :bg_img_url, :style_bg_img_tile] =>
            re_group('', /body[^\}]*background: #([\da-f]+) url\((http[^\)]*)\) ([^;]*);/si),
        }),
      :friends                => ['div.section/div#friends/span.vcard', {
          :twitter_name         => href('a', %r{http://twitter.com/(.*)}),
          :mini_img_url         => src('a/img.fn')
        }],
      :tweets                 => ["#{status_box}/div.hfeed//.hentry", {
          :tweet_id             => to_num('', href('.entry-meta/a.entry-date[@rel="bookmark"]', %r{http://twitter.com/[^/]+/statuses/([^/]*)})),
          :content              => strip('.entry-content'),
          :datetime             => attr('.entry-meta/a.entry-date/abbr','title'),
          :all_atsigns          => re_all('.entry-content', %r{@<a href="/([^>]+)"}),
          :all_hash_tags        => re_all('.entry-content', %r{\#(\w+)}),
          :all_tweeted_urls     => ['.entry-content/a:not([@href^="/"])', href('')],
          [:fromsource_url, :fromsource]         => re_group('.entry-meta', %r{from\s+<a href="([^\"]+)">([^<]+)</a>}),
          [:inreplyto_name, :inreplyto_tweet_id] => re_group('.entry-meta', %r{http://twitter.com/([^/]+)/statuses/([^>]+)\">in reply to}),
        }],
    }
  end
end

def natural_merge dest, raw, only=nil
  raw = raw.slice(*only) if only
  # raw.each{|k,v| dest[k] = v if v }
  dest.attributes = raw.compact if raw #
end

def parse_twitter_user twitter_user, profile_page_filename
  return if (!twitter_user) || twitter_user.parsed || twitter_user.failed
  return unless File.exist?(profile_page_filename)
  File.open(profile_page_filename) do |profile_page_file|
    begin
      doc = Hpricot(profile_page_file)
    rescue
      twitter_user.parsed = false; twitter_user.failed = true; twitter_user.save
      return
    end
    raw = $parser.parse(doc)
    twitter_user.last_scraped_date = File.mtime(profile_page_file)
    natural_merge twitter_user, raw, [:native_id, :profile_img_url]
    natural_merge twitter_user, raw[:profile]
    natural_merge twitter_user, raw[:stats]
    raw[:style_settings] ||= {}
    [:style_link_color, :style_text_color, :style_name_color, :style_bg_color, :style_sidebar_fill_color, :style_sidebar_border_color].each do |attr|
      raw[:style_settings][attr] = raw[:style_settings][attr].hex if raw[:style_settings][attr]
    end
    raw[:style_settings][:style_bg_img_tile] = !!(raw[:style_settings][:style_bg_img_tile] =~ /no-repeat/)
    natural_merge twitter_user, raw[:style_settings]
    raw[:friends].each do |hsh|
      next unless hsh[:twitter_name]
      friend = TwitterUser.update_or_create({ :twitter_name => hsh[:twitter_name] }, { :mini_img_url => hsh[:mini_img_url]})
      Friendship.find_or_create(:friend_id => friend.id, :follower_id => twitter_user.id)
    end
    raw[:tweets].each do |raw_tweet|
      tweet_id_str = raw_tweet.delete(:tweet_id) or next
      tweet_id = tweet_id_str.to_i
      raise "Bad tweet id in #{twitter_name}: #{tweet_id_str.inspect} - #{raw_tweet.inspect}" unless (tweet_id && (tweet_id > 0))
      [:all_atsigns, :all_hash_tags, :all_tweeted_urls].each do |attr| raw_tweet[attr] = raw_tweet[attr].to_json if raw_tweet[attr] end
      raw_tweet[:inreplyto_tweet_id] = raw_tweet[:inreplyto_tweet_id].to_i if raw_tweet[:inreplyto_tweet_id]
      tweet = Tweet.update_or_create({ :id => tweet_id }, raw_tweet.merge({ :twitter_user_id => twitter_user.id }))
    end
    # first_tweet = twitter_user.tweets.first(:order => [:datetime.asc])
    # last_tweet  = twitter_user.tweets.first(:order => [:datetime.desc])
    # twitter_user.first_seen_update_time = first_tweet.datetime if first_tweet
    # twitter_user.last_seen_update_time  = last_tweet.datetime  if last_tweet
    twitter_user.parsed = true
    twitter_user.save
    # puts raw.to_yaml
  end
  return true
end

def ripd_file_from_name twitter_name
  prefix = (twitter_name+'_')[0..1]
  "/data/rawd/social/network/twitter_friends/profiles/twitter_id_#{prefix}/#{twitter_name}"
end


def popular_pass threshold, offset = 0
  repository(:default).adapter.query('')
end


def parse_pass threshold, offset = 0
  announce("Parsing %6d..%-6d popular but unparsed users" % [offset, threshold+offset])
  popular_and_neglected = AssetRequest.all :scraped_time => nil, :user_resource => 'parse',
     # 'twitter_user.bg_img_url' => nil,
     # :conditions => [ 'twitter_users.followers_count >= 100' ],
     :fields => [:twitter_name, :id, :twitter_user_id, :priority],
     :order  => [:priority.asc],
     :limit  => threshold, :offset => offset
  popular_and_neglected.each do |req|
    profile_page_filename = ripd_file_from_name(req.twitter_name)
    next unless req.twitter_user
    track_count    :users, 10
    $stderr.print "%d-%-18s"%[req.priority, req.twitter_name]
    success = parse_twitter_user req.twitter_user, profile_page_filename
    # mark columns
    req.result_code  = success
    req.scraped_time = Time.now.utc
    req.save
  end
  announce "Finished chunk %6d..%-6d" % [offset, threshold+offset]
end

$parser = TwitterHTMLParser.new()
n_requests = AssetRequest.count( :user_resource => 'parse' )
chunksize = 500
offset    = 4000
chunks    = (n_requests / chunksize).to_i + 1
(1..chunks).each do |chunk|
  parse_pass chunksize, offset
end
