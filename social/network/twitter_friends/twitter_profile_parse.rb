#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'imw/extract/hpricot'
require 'imw/utils'
require 'imw/dataset/datamapper'
require 'json'
include IMW; IMW.verbose = true
as_dset __FILE__

#
# Setup database
#
require 'twitter_friends_db_definition'; setup_twitter_friends_connection()
require 'twitter_profile_model'

# Identify 2,000 and 2000 just the same
def to_num(i)       i.gsub(/,/,'').to_i     end
# matches color defs in the user style's css snippets
COLOR_RE = %r{color\:\s*.([\da-f]+)}

# take off common s3 head,

class User
  #
  #
  #
  def parse
    begin
      doc = Hpricot(File.open(profile_page_filename))
    rescue
      self.parsed = false; self.save
      return false
    end
    # Basic info
    self.file_date     = File.mtime(profile_page_filename)
    self.twitter_id    = (doc/'head/link[@href*=".rss"]').to_s.gsub(%r{.*user_timeline/(\d+)\.rss.*}, '\1')
    el_sidebar         = doc.at('body/div#container/div#side_base/div#side') or return
    parse_stats          (el_sidebar/('div.section/ul.stats/li'))
    parse_self_info      (el_sidebar/('div.section/address/ul.entry-author/li'))
    parse_style_settings (doc/('head/style[@type^=text]')).to_s

    # Relations
    parse_friends        (el_sidebar/('div.section/div#friends/span.vcard/a'))
    parse_statuses       doc.at('body/div#container/div#content/div.wrapper')

    # a few more rough stats
    last_seen_update  = self.statuses.first(:order => [:datetime.desc])
    first_seen_update = self.statuses.first(:order => [:datetime.asc])
    self.last_seen_update_time  = last_seen_update.datetime  if last_seen_update
    self.first_seen_update_time = first_seen_update.datetime if first_seen_update

    # OK, save the model
    self.parsed = true
    self.save

    # Diagnostics
    announce "    * #{twitter_name}"
    # puts [friends, followers].to_json; $stdout.flush
  end

  def analyze_status status
    m = nil
    status.users_atsigned = m.captures.to_json if (m = %r{@<a href="/([^\"]+)">}.match(status.content))
    status.hashtags       = m.captures.to_json if (m = %r{\#(\w+)}.match(status.content))
    status.content_urls   = m.captures.to_json if (m = %r{href="https?://([^\"]+)"}.match(status.content))
    status
  end

  # Status
  def parse_status el_status
    status = Status.new(:user => self)
    # status.twitter_id = el_status.attributes['id'].gsub(/status_/, '').to_i
    status.content    = el_status.contents_of('.entry-content')
    if ! status.content then
      warn "NO:"+el_status.to_s unless (el_status.to_s =~ /Haven.*t updated yet/s) || (el_status.to_s =~ /\A\s*\z/s)
      return
    end
    status.content.strip!
    date_el = el_status.at('.entry-meta/a.entry-date/abbr')
    status.datetime   = date_el.attributes['title'] if date_el
    metainfo = el_status.contents_of('.entry-meta')
    if metainfo =~ (%r{from\s+<a href="([^"]+)">([^<]+)</a>}s) #### "})
      status.fromsource_url, status.fromsource = [$1, $2]
    end
    if metainfo =~ (%r{<a href="http://twitter.com/([^\"]+)/statuses/(\d+)">in reply to (?:[^<]+)</a>}s)
      status.inreplyto_name, status.inreplyto_status_id = [$1, $2]
    end
    analyze_status status
    status.save
    status
  end

  # Profile image
  def get_profile_img_url(el_content)
    img_el = el_content.at('h2.thumb/a/img#profile-image')
    img_el.attributes['src'] if img_el
  end

  # grok the status block
  def parse_statuses el_content
    self.style_profile_img_url = get_profile_img_url(el_content)
    status = parse_status(el_content/'div.hfeed/div.hentry')
    self.statuses << status if status
    (el_content/'div.hfeed/div.tab/table#timeline//tr').each do |el_status|
      status = parse_status(el_status)
      self.statuses << status if status
    end
  end

  # Stats from the sidebar: followers, friends, number of updates, ...
  def parse_stats el_stats
    self.following_count = to_num(el_stats.contents_of('span#following_count'))
    self.followers_count = to_num(el_stats.contents_of('span#followers_count'))
    self.favorites_count = to_num(el_stats.contents_of('span#favourites_count')) # note 'u'
    el_updates           = el_stats.find{|el| el.inner_html =~ %r{Updates.*<span[^>]+>([,\d]+)</span>} }
    self.updates_count   = to_num($1) if el_updates
  end

  # Name, address, website and bio
  def parse_self_info el_addr
    self.real_name       = el_addr.contents_of('span.fn')
    self.location        = el_addr.contents_of('span.adr')
    self.web             = el_addr.at('a.url').attributes['href'] if el_addr.at('a.url')
    self.bio             = el_addr.contents_of('span.bio')
  end

  # Friend links
  #  (and also mini_image urls, which are otherwise unguessable)
  def parse_friends vcards
    vcards.each do |el|
      parse_friend el
    end
  end
  def parse_friend el
    # Here's a user!
    friend_name = el.attributes['href'].gsub(%r{https?://(?:\w+\.)?twitter.com/}, '')
    friend = User.find_or_create(:twitter_name => friend_name)
    friend.style_mini_img_url ||= el.at('img.fn').attributes['src']
    # Let's be friends!
    friend.save
    self.friendships << Friendship.new(:friend => friend)
  end

  def parse_style_settings el_styles
    self.style_name_color           = $1.hex if el_styles =~ /h2.thumb\s+a\s*\{#{COLOR_RE};/si
    self.style_link_color           = $1.hex if el_styles =~ /a \{#{COLOR_RE};/si
    self.style_text_color           = $1.hex if el_styles =~ /body[^\}\;]*#{COLOR_RE};/si
    self.style_bg_color             = $1.hex if el_styles =~ /body[^\}]*background-#{COLOR_RE};/si
    self.style_sidebar_fill_color   = $1.hex if el_styles =~ /#side[^\}\;]*background-#{COLOR_RE};/si
    self.style_sidebar_border_color = $1.hex if el_styles =~ /#side[^\}\;]*border\:[^;]+#([\da-f]+);/si
    if el_styles =~ /body[^\}]*background: #([\da-f]+) url\((http[^\)]*)\) ([^;]*);/si
      img_url, img_tile = [$2, $3]
      self.style_bg_img_tile        = img_tile && ((img_tile =~ /no-repeat/) ? true : false)
      self.style_bg_img_url         = img_url unless (img_url =~ %r{http://.*\.twitter\.com/images/bg.gif})
    end
  end

end


filemask = ARGV[0] ; if filemask.blank? then raise "need to give a file mask or just a '*'" end
twitter_followers = {}
User.users_with_profile(filemask) do |user|
  track_progress :profile, user.twitter_name[0..0].downcase
  begin
    user.parse unless user.parsed
  rescue Exception => e
    warn "Failed to parse #{user.twitter_name}: #{e}"
    # user.parsed = false; user.save
  end
end

