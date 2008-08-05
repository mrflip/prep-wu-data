#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'imw/extract/hpricot'
require 'imw/utils'
require 'JSON'
include IMW; IMW.verbose = true
as_dset __FILE__
#
# Setup database
#
require 'imw/dataset/datamapper'
DataSet.setup_connection :mysql, 'imw', 'local_pass_14_312', 'localhost', 'imw_twitter_friends'
# DataMapper::setup(:default, "sqlite3:///#{Dir.pwd}/fixd/db/twitter_friends.sqlite")
require 'twitter_profile_model'

# TWITTER_NAME_RE = %r{^ +<a href="http://twitter.com/([^"]+)" class="url" rel="contact"} #"
# def extract_following(user)
#   puts "\t...people #{user.twitter_name} is following"
#   File.open(user.following_filename, "w") do |following_file|
#     File.open(user.profile_page_filename){|f| f.readlines }.each do |line|
#       if line =~ TWITTER_NAME_RE
#         following_file << "#{$1}\n"
#       end
#     end
#   end
# end

def to_num i
  i.gsub(/,/,'').to_i
end

COLOR_RE = %r{color\:\s*.([\da-f]+)}
class User
  def parse
    doc = Hpricot(File.open(profile_page_filename))

    # self.file_date = File.mtime(profile_page_filename)
    # self.twitter_id = (doc/'head/link[@href*=".rss"]').to_s.gsub(%r{.*user_timeline/(\d+)\.rss.*}, '\1')

    # Sidebar
    el_sidebar = doc.at('body/div#container/div#side_base/div#side')
    el_stats   = el_sidebar/('div.section/ul.stats/li')
    self.following_count = to_num(el_stats.contents_of('span#following_count'))
    self.followers_count = to_num(el_stats.contents_of('span#followers_count'))
    self.favorites_count = to_num(el_stats.contents_of('span#favourites_count')) # note 'u'
    el_updates           = el_stats.find{|el| el.inner_html =~ %r{Updates.*<span[^>]+>([,\d]+)</span>} }
    self.updates_count   = to_num($1) if el_updates

    el_addr    = el_sidebar/('div.section/address/ul.entry-author/li')
    self.real_name       = el_addr.contents_of('span.fn')
    self.location        = el_addr.contents_of('span.adr')
    self.web             = el_addr.at('a.url').attributes['href'] if el_addr.at('a.url')
    self.bio             = el_addr.contents_of('span.bio')

    (el_sidebar/('div.section/div#friends/span.vcard/a')).each do |el|
      friend_name = el.attributes['href'].gsub(%r{https?://(?:\w+\.)?twitter.com/}, '')
      friend = User.first(:twitter_name => friend_name) || User.new(:twitter_name => friend_name)
      friend.style_mini_img_url ||= el.at('img.fn').attributes['src']
      friend.save
      puts "  #{self.twitter_name} => #{friend.twitter_name}"
      self.followers << friend
      self.save
    end

    el_styles = (doc/('head/style[@type^=text]')).to_s
    self.style_name_color           = $1.hex if el_styles =~ /h2.thumb\s+a\s*\{#{COLOR_RE};/si
    self.style_link_color           = $1.hex if el_styles =~ /a \{#{COLOR_RE};/si
    self.style_text_color           = $1.hex if el_styles =~ /body[^\}\;]*#{COLOR_RE};/si
    self.style_bg_color             = $1.hex if el_styles =~ /body[^\}]*background-#{COLOR_RE};/si
    self.style_sidebar_fill_color   = $1.hex if el_styles =~ /#side[^\}\;]*background-#{COLOR_RE};/si
    self.style_sidebar_border_color = $1.hex if el_styles =~ /#side[^\}\;]*border\:[^;]+#([\da-f]+);/si
    if el_styles =~ /body[^\}]*background: #([\da-f]+) url\((http[^\)]*)\) ([^;]*);/si
      self.style_bg_img_url         = $2
      self.style_bg_img_tile        = $3
    end

    self.save
    puts self.attributes.reject{|k,v| v.nil? }.to_json
    $stdout.flush
  end
end


twitter_followers = {}
User.users_with_profile do |user|
  track_progress :profile, user.twitter_name[0..0].downcase
  user.parse
end




#   # unless File.exist? user.following_filename
#   #   extract_following(user)
#   # end
#   # File.open(user.following_filename){|f| f.readlines }.each do |followed_name|
#   #   followed_name.chomp!
#   #   twitter_followers[followed_name] ||= 0
#   #   twitter_followers[followed_name]  += 1
#   # end
# # twitter_followers = twitter_followers.sort_by{ |follower, n| [-n, follower] }
# # DataSet.dump({ :names => twitter_followers }, User.names_index_filename)
