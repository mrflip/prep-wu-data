#!/usr/bin/env rake -f
require  File.dirname(__FILE__)+'/delicious_link_models.rb'

def delicious_page tag, page, user='tag', count=100, detail=3
  %{delicious.com/%s/%s?detail=%s&setcount=%s&page=%s} % [user, tag, detail, count, page]
end

def wget url
  sh %{ wget -nv -x "http://#{url}" }
  sleep 1.5
end

task :default => 'tags:all'

namespace :tags do
  #
  # Modest scrape of tagged datasets from delicious
  #
  [
    ['datasource+stats',         2],
    ['dataset',                 20],
    ['dataset+database',         7],
    ['dataset+stats',            3],
    ['dataset+statistics',       6],
    ['dataset+research',         8],
    ['dataset+reference',        4],
    ['datasets',                20],
    ['datasets+database',        9],
    ['datasets+stats',           5],
    ['datasets+statistics',     20],
    ['datasets+research',       10],
    ['datasets+reference',       6],
    ['data+statistics',         20],
    ['data+stats',              20],
    ['ckan',                     2],
    ['ckantodo',                 5],
  ].each do |tag, pglimit|
    (1..pglimit).to_a.each do |page|
      del_url = delicious_page(tag, page)
      file (del_url) do |t|
        wget del_url
      end
      task :all => del_url
    end
  end

  #
  # some users with good personal colxns
  #
  ['mrflip', 'pskomoroch'].each do |user|
    [
      ['dataset',       4],
      ['datasets',      4],
      ['datasource',    2],
      ['datasources',   2],
      ['data+source',   2],
    ].each do |tag, pglimit|
      (1..pglimit).to_a.each do |page|
        del_url = delicious_page(tag, page, user)
        file (del_url) do |t|
          wget del_url
        end; task :all => del_url
      end
    end
  end

  #
  # Other random ones
  #
  %w[
        conflate.net/inductio/2008/02/a-meta-index-of-data-sets/index.html
        delicious.com/search/index.html?p=ckan+data
        delicious.com/search/index.html?p=ckantodo
        www.data360.org/ds_list.aspx
        www.dataplace.org/web_data_links.html
        www.datawrangling.com/some-datasets-available-on-the-web
        www.programmableweb.com/apitag/uk
        www.readwriteweb.com/archives/where_to_find_open_data_on_the.php
        www.statsci.org/datasets.html
        www.trustlet.org/wiki/Repositories_of_datasets
        bioinformatics.ca/links_directory
        lsrn.org/lsrn/registry.html
        shirleyfung.com/mbdb/index.php
        www.chemspider.com/DataSources.aspx
        www.essex.ac.uk/linguistics/clmt/w3c/corpus_ling/content/corpora/list
        www.grsampson.net/Resources.html
        www.inf.ed.ac.uk/resources/corpora
        okfn.org/wiki/OpenEnvironmentalData
        www.ckan.net/images/ckan.sql.gz
    ].each do |url|
    file url do |t|
      wget url
    end; task :all => url
  end


end

# http://delicious.com/pskomoroch/dataset?detail=3&pagecount=100&page=4


# http://delicious.com/help/html
# http://feeds.delicious.com/v2/{format}
# *  {format} = replaced with either "rss" or "json"
# * {username} = replaced with a user's login name on delicious
# * {tag[+tag+...+tag]} = replaced with a tag or an intersection of tags.
# * {url md5} = is intended for the MD5 hash of a URL
# * {key} = a security key for the feed, which can be found via the page associated with the feed (eg. inbox).
# ?count={1..100} ?plain
