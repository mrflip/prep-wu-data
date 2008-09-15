#!/usr/bin/env ruby
require 'rubygems'
require 'dm-core'
require 'fileutils'; include FileUtils
require 'imw'; include IMW
require 'imw/dataset'
require 'imw/dataset/asset'
require 'imw/extract/html_parser'
as_dset __FILE__




DataMapper::Logger.new(STDOUT, :debug) # uncomment to debug
DataMapper.setup_remote_connection IMW::ICS_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'ics_scaffold_indexes' })

class SimpleProcessor
  include Asset::Processor

  def define_link hsh
    link = Link.find_or_create({ :full_url => hsh['link_url'] }, {
        :name        => hsh['link_title'],
      })
    link.wget :wait => 0 # this is ok, we only fetch ~1 per site
    link.save
    link
  end

  def define_associations dataset, link
    linking = Linking.find_or_create({:link_id => link.id, :role => 'main',
        :linkable_id => dataset.id, :linkable_type => dataset.class.to_s  })
    linking.save
  end

  def define_dataset hsh, contributors
    # puts '*'*75, hsh.slice(:user_name, :linker_tag_url).to_json
    ds = Dataset.find_or_create({ :handle => hsh['link_url'] })
    ds.attributes = hsh.slice('description', 'category', 'is_collection').merge({:name => hsh['link_title'],})
    ds.set_fact :fact, :collection_id, hsh['collection_id']
    ds.fact_hash.delete :geonamesorg

    tag_strs = hsh['tag_list'].split(/ /).map{|tag| tag.gsub(/[^\w]/, '_') }
    tag_strs.each do |tag_str|
      tag     = Tag.find_or_create({ :name => tag_str })
      tagging = Tagging.find_or_create({
          :tag_id      => tag.id,               :context       => :tags,
          :taggable_id => ds.id,                :taggable_type => ds.class.to_s,
          :tagger_id   => contributors['flip.infochimps.org'].id,  :tagger_type   => Contributor.to_s,
        })
    end
    geonames_contrib = contributors['http://www.geonames.com']
    credit = Credit.find_or_create({
        :dataset_id => ds.id, :contributor_id => geonames_contrib.id, :role => hsh['credits']['role'] },
      hsh['credits'].slice('desc', 'citation'))
    ds.save
    ds
  end

  def define_contributor hsh
    contributor = Contributor.find_or_create({
        :handle => hsh['handle']  }, hsh)
  end

  def parse
    global_attributes = YAML.load(File.open('geonames_template.icss.yaml'))
    MANUAL_POSTAL_CODES.each do |source_url, country|
      hsh = {
        'link_url'    => source_url,
        'link_title'  => "Postal Codes for #{country}",
        'description' => "Postal Codes for #{country}"
      }
      contributors = { }
      global_attributes['contributors'].each do |contributor_hsh|
        contributors[contributor_hsh['handle']] = define_contributor(contributor_hsh)
      end
      dataset     = define_dataset      global_attributes['datasets'].first.merge(hsh), contributors
      link        = define_link         hsh
      define_associations dataset, link
    end
  end

end

#
# Gah. Annoyingly hand-recovered from:
#   www.geonames.org/postal-codes-sources.html
#
MANUAL_POSTAL_CODES = {
        "http://www.easyreserve.com"                            => "Italy (IT)",
        "http://inmadrid.enredados.com/"                        => "Spain (ES)",
        "http://nl.wikipedia.org"                               => "The Netherlands (NL)",
        "http://posta.org.md"                                   => "Moldova (MD)",
        "http://www.ungheni-labs.com"                           => "Moldova (MD)",
        "http://sourceforge.net/projects/opengeodb"             => "Germany (DE)",
        "http://www.arrakis.es/~pocha/"                         => "Spain (ES)",
        "http://www.auspost.com.au"                             => "Australia (AU)",
        "http://www.bangladeshpost.gov.bd"                      => "Bangladesh (BD)",
        "http://www.brainstorm.co.uk"                           => "United Kingdom (UK)",
        "http://www.correoargentino.com.ar/"                    => "Argentina (AR)",
        "http://www.cpost.cz"                                   => "Czech Republic (CZ)",
        "http://www.ctt.pt"                                     => "Portugal (PT)",
        "http://www.ept.lu"                                     => "Luxembourg (LU)",
        "http://www.freethepostcode.org"                        => "United Kingdom (UK)",
        "http://www.indiapost.gov.in"                           => "India (IN)",
        "http://www.jibble.org"                                 => "United Kingdom (UK)",
        "http://www.lacnet.org/slnews/postal_codes.html"        => "Sri Lanka (LK)",
        "http://www.npemap.org.uk"                              => "United Kingdom (UK)",
        "http://www.nzpost.co.nz"                               => "New Zealand (NZ)",
        "http://www.pakpost.gov.pk"                             => "Pakistan (PK)",
        "http://www.pellesoft.se/upload/program/prg00745.zip"   => "Sweden (SE)",
        "http://www.poczta-polska.pl"                           => "Poland (PL)",
        "http://www.post.at"                                    => "Austria (AT)",
        "http://www.post.be"                                    => "Belgium (BE)",
        "http://www.post.ch"                                    => "Liechtenstein (LI)",
        "http://www.post.ch"                                    => "Switzerland (CH)",
        "http://www.posta.com.mk"                               => "Macedonia (MK)",
        "http://www.posta.hr"                                   => "Croatia (HR)",
        "http://www.posta.hu"                                   => "Hungary (HU)",
        "http://www.posta.si"                                   => "Slovenia (SI)",
        "http://www.postdanmark.dk"                             => "Denmark (DK)",
        "http://www.poste.it"                                   => "Italy (IT)",
        "http://www.poste.it"                                   => "San Marino (SM)",
        "http://www.posten.no"                                  => "Norway (NO)",
        "http://www.postur.is"                                  => "Iceland (IS)",
        "http://www.sapo.co.za"                                 => "South Africa (ZA)",
        "http://www.sepomex.gob.mx"                             => "Mexcio (MX)",
        "http://www.slposta.sk"                                 => "Slovakia (SK)",
        "http://www.thailandpost.com"                           => "Thailand (TH)",
        "http://www.unice.fr/cgi-bin/codePostal"                => "France (FR)",
        "http://www.verkkoposti.com/e3/postinumeroluettelo"     => "Finland (FI)",
}

processor = SimpleProcessor.new
processor.parse
