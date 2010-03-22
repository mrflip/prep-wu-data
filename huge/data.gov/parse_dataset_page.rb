require File.dirname(__FILE__) + "/get_dataset_pages"
require File.dirname(__FILE__) + "/raw_objects"
require 'imw/parsers/html_parser'

IMW.add_path :prsd, "prsd"

# :id, :title, :agency, :sub_agency, :category, :created_at, :updated_at, :time_period_begins, :time_period_ends, :frequency, :description, :category_type, :category_designation, :keywords, :citation, :agency_page, :agency_data_series, :unit, :granularity, :geo_coverage, :collection_mode, :collection_instrument, :variable_list, :technical_documentation, :additional_metadata, :statistical_methodology, :sampling, :estimation, :weighting, :disclosure, :questionnaire, :series_breaks, :non_response, :seasonal, :statistical_characteristics, :rating_overall, :rating_utility, :rating_usefulness, :rating_access, :download_format, :download_path, :download_size

PARSER = {
  :title => "h1",
  :property_rows  => IMW::HTMLParserMatcher::MatchArray.new(["table.details-table//tr"], nil, :html => true)
}


class TableRow
  
  MAPPINGS = {
    /^Agency/ => :agency,
    /^Sub-Agency/ => :sub_agency,
    /^Category/ => :category,
    /^Date Released/ => :created_at,
    /^Date Updated/ => :updated_at,
    /^Time Period/ => :time_period,
    /^Frequency/ => :frequency,
    /^Description/ => :description,
    /^Data\.gov Data Category Type/ => :category_type,
    /^Specialized Data Category Designation/ => :category_designation,
    /^Keywords/ => :keywords,
    /^Unique ID/ => :data_gov_id, # can get it from the page URL as well
    /^Citation/ => :citation,
    /^Agency Program Page/ => :agency_page,
    /^Agency Data Series Page/ => :agency_data_series,
    /^Unit of Analysis/ => :unit,
    /^Granularity/ => :granularity,
    /^Geographic Coverage/ => :geo_coverage,
    /^Collection Mode/ => :collection_mode,
    /^Data Collection Instrument/ => :collection_instrument,
    /^Data Dictionary/ => :variable_list,
    /^Technical Documentation/ => :technical_documentation,
    /^Additional Metadata/ => :additional_metadata,
    /^Statistical Methodology/ => :statistical_methodology,
    /^Sampling/ => :sampling,
    /^Estimation/ => :estimation,
    /^Weighting/ => :weighting,
    /^Disclosure avoidance/ => :disclosure,
    /^Questionnaire design/ => :questionnaire,
    /^Series breaks/ => :series_breaks,
    /^Non-response adjustment/ => :non_response,
    /^Seasonal adjustment/ => :seasonal,
    /^Statistical Characteristics/ => :statistical_characteristics,
    /^FGDC Compliance/ => :fgdc
  }
  
  attr_reader :html
  def initialize html
    @html = html
    @html = Hpricot(html) if @html.is_a?(String)
  end

  def name
    @name  ||= html.at("td[1]").inner_text.strip.tr("\n\r",' ').gsub(/	/,' ').gsub(/ +/,' ')
  end

  def value
    @value ||= html.at("td[2]").inner_text.tr("\n\r",' ').gsub(/	/, ' ').gsub(/ +/, ' ')
  end
  
  def property_value_pair
    match = MAPPINGS.find { |regexp, property| regexp =~ name }
    puts "WARNING: Could not map row:\n#{html}\nname: '#{name}'\nvalue: '#{value}'" unless match
    match ? { match.last => value } : {}
  end
end

class DownloadLink
  attr_reader :html
  def initialize html
    @html = html
    @html = Hpricot(html) if @html.is_a?(String)
  end

  def link
    html
  end

  def has_download?
    link[:href] =~ %r{^/download/[0-9]+/}
  end
  
  def path
    @path ||= link[:href]
  end

  def format
    @format ||= File.basename(path)
  end

  def size
    link.inner_text.tr("\n\r",' ').gsub(/	/, ' ').gsub(/ +/, ' ')
  end
  
end


def parse_dataset_page path
  page = IMW.open(IMW.path_to(path))  
  data = page.parse(PARSER)
  data[:property_rows].each do |row_html|
    row = TableRow.new(row_html)
    prop_pair = row.property_value_pair
    data.merge!(prop_pair)
  end
  data.delete(:property_rows)

  download_links = (page/"table.download-table//a").to_a.flatten

  download_links.each do |link|
    link = DownloadLink.new(link)
    next unless link.has_download?
    data[:download_path]   = link.path
    data[:download_format] = link.format
    data[:download_size]   = link.size
    break
  end

  page.at("td.votes.ratepad").at("img")[:src] =~ /([0-9])/
  data[:rating_overall] = $1.to_i
  RawDataset.new(data)
end

def parse_datasets_into_yaml
  FileUtils.mkdir_p IMW.path_to(:prsd)
  datasets = Dir[IMW.path_to(:rawd) + "/*.html"].map { |path| parse_dataset_page(path) }
  File.open(IMW.path_to(:prsd, "datasets.yaml"), 'w') { |f| f.write(datasets.to_yaml) }
end

if $0 == __FILE__
  if ARGV.blank?
    parse_datasets_into_yaml
  else
    ARGV.each do |path|
      puts parse_dataset_page(path).pretty_print
    end
  end
end


