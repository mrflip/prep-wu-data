#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw/utils'; include IMW; IMW.verbose = true
require 'imw/extract/hpricot'
require 'imw/extract/html_parser.rb'
require 'json'
require 'yaml'
require  File.dirname(__FILE__)+'/delicious_link_models.rb'
as_dset __FILE__
# as_dset 'urls/bulk/delicious', :cut_dirs => 0

UNFETCHED_URLS_QUERY = %{
  SELECT d.delicious_id, d.num_delicious_savers AS popularity, d.link_url, d.title
    FROM        delicious_links d
    LEFT JOIN   ripped_urls     r  ON d.delicious_id = r.rippable_param AND r.rippable_type = 'url'
    WHERE       ripd_url IS NULL AND d.num_delicious_savers < 2101
    ORDER BY popularity DESC
}

UNFETCHED_USERS_QUERY = %{
  SELECT sld.socialite_name, sld.popularity
    FROM (
      SELECT s.name as socialite_name, COUNT(*) AS popularity
        FROM          socialites_links sl
        LEFT JOIN socialites      s   ON sl.socialite_id      = s.id
        LEFT JOIN delicious_links d   ON sl.delicious_link_id = d.id
        WHERE 1
        GROUP BY s.name
        ORDER BY popularity DESC
        LIMIT 8000) sld
    LEFT JOIN ripped_urls r       ON sld.socialite_name = r.rippable_user AND r.rippable_type = 'user'
    WHERE ripd_url IS NULL AND popularity > 4
    GROUP BY socialite_name
    ORDER BY popularity DESC
    LIMIT 8000
}
#FIXME -- Above query won't fetch unless pg 0 is there.

def wget ripd_file
  cd path_to(:ripd_root) do
    if File.exists?(ripd_file) then
      # puts "Skipping #{ripd_file}";
      return ;
    end
    print `wget -x -nv "http://#{ripd_file}" `
    success = File.exists?(ripd_file)
    FileUtils.touch ripd_file  # leave a 0-byte turd so we don't refresh
    sleep 90
    return success
  end
end

def delicious_feed_link *pathsegs
  # options = options.reverse_merge :format => :json
  format = :json
  urlbase = "feeds.delicious.com/v2"
  [urlbase, format, *pathsegs].flatten.map(&:to_s).join('/')
end

def delicious_link_from_url_id url_id
  %{delicious.com/url/#{url_id}}
end

def delicious_link_from_user_id user_id
  %{delicious.com/#{user_id}}
end

URL_QUERY_STR = "detail=3&setcount=100&"
def delicious_link_page_n ripd_file, page
  "#{ripd_file}?#{URL_QUERY_STR}page=#{page}"
end

def wget_many_pages ripd_file, nlinks
  wget ripd_file                        # get first page w/ no query string
  # pages = [nlinks/100, 4].min          # get rest w/ page number
  # (2..pages).each do |page|
  #   wget delicious_link_page_n(ripd_file, page)
  # end
end

def get_delicious_json item, val
  case item
  when :user
    return if user =~ /!/ # bogosity marker
    wget delicious_feed_link(                 user)
    wget delicious_feed_link(:userinfo,       user)
    wget delicious_feed_link(:networkmembers, user)
    wget delicious_feed_link(:networkfans,    user)
  when :url, :urlhash then
    wget delicious_feed_link(:url, val)
  when :tag     then
    wget delicious_feed_link(:tag, val)
  end
end

def json_get_users
  repository(:default).adapter.query('SELECT s.name as socialite_name, s.id AS popularity FROM socialites s ORDER BY popularity').each do |struct|
    user, popularity = struct.to_a
    announce "%5d current links, user %s" % [popularity, user]
    get_delicious_json :user, user
  end
end

def html_wget_users
  repository(:default).adapter.query(UNFETCHED_USERS_QUERY).each do |struct|
    delicious_user_id, popularity = struct.to_a
    next if delicious_user_id =~ /!/ # bogosity marker
    announce "%5d current links, user %s" % [popularity, delicious_user_id]
    wget delicious_link_page_n(delicious_link_from_user_id(delicious_user_id), 1)
  end
end
def html_wget_urls
  repository(:default).adapter.query(UNFETCHED_URLS_QUERY).each do |struct|
    delicious_url_id, popularity, link_url, link_title = struct.to_a
    announce "%5d saves: %-40s %-40s " % [popularity, (link_url||'')[6..45], (link_title||'')[0..39]]
    wget_many_pages delicious_link_from_url_id(delicious_url_id), popularity
  end
end
