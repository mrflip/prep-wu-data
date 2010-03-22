require 'rubygems'
require 'ostruct'

class RawDataset < OpenStruct

  # property :id, Serial

  # property :title, String

  # property :agency, String
  # property :sub_agency, String
  # property :category, String

  # property :created_at, DateTime
  # property :updated_at, DateTime

  # property :time_period, String

  # property :frequency, String
  # property :description, Text

  # property :category_type, String
  # property :category_designation, String

  # property :keywords, String

  # property :citation, String
  # property :agency_page, String
  # property :agency_data_series, String

  # property :unit, String
  # property :granularity, String
  # property :geo_coverage, String

  # property :collection_mode, String
  # property :collection_instrument, String
  # property :variable_list, String

  # property :technical_documentation, String
  # property :additional_metadata, String

  # property :statistical_methodology, String
  # property :sampling, String
  # property :estimation, String
  # property :weighting, String
  # property :disclosure, String
  # property :questionnaire, String
  # property :series_breaks, String
  # property :non_response, String
  # property :seasonal, String
  # property :statistical_characteristics, String

  # property :rating_overall, Integer
  # property :rating_utility, Integer
  # property :rating_usefulness, Integer
  # property :rating_access, Integer

  # property :download_format, String
  # property :download_path, String
  # property :download_size, String

  # property :fgdc, String

  

  # Make it look sort of like at data.gov for easy visual comparison
  #   def pretty_print
  #     <<EOF
  # #{title}

  # DATASET SUMMARY
  # ================================================================
  # Agency:        #{agency}
  # Sub-Agency:    #{sub_agency}
  # Category:      #{category}
  # Date Released: #{created_at}
  # Date Updated:  #{updated_at}
  # Time Period:   #{time_period}
  # Frequency:     #{frequency}
  # Description:   #{description}

  # DATASET RATINGS
  # ================================================================
  # Overall:        #{"* " * (rating_overall || 0)}
  # Data Utility:   #{"* " * (rating_utility || 0)}
  # Usefulness:     #{"* " * (rating_usefulness || 0)}
  # Ease of Access: #{"* " * (rating_access || 0)}

  # DATASET INFORMATION
  # ================================================================
  # Data.gov Data Category Type:           #{category_type}
  # Specialized Date Category Designation: #{category_designation}
  # Keywords:                              #{keywords}
  # Unique ID:                             #{id}

  # CONTRIBUTING AGENCY INFORMATION
  # ================================================================
  # Citation:                #{citation}
  # Agency Program Page:     #{agency_page}
  # Agency Data Series Page: #{agency_data_series}

  # DATASET COVERAGE
  # ================================================================
  # Unit of Analysis:    #{unit}
  # Granularity:         #{granularity}
  # Geographic Coverage: #{geo_coverage}

  # DATA DESCRIPTION
  # ================================================================
  # Collection Mode:               #{collection_mode}
  # Data Collection Instrument:    #{collection_instrument}
  # Data Dictionary/Variable List: #{variable_list}

  # ADDITIONAL DATASET DOCUMENTATION
  # ================================================================
  # Technical Documentation:           #{technical_documentation}
  # FGDC Compliance (Geospatial Only): #{fgdc}
  # Additional Metadata:               #{additional_metadata}

  # STATISTICAL INFORMATION
  # ================================================================
  # Statistical Methodology:     #{statistical_methodology}
  # Sampling:                    #{sampling}
  # Estimation:                  #{estimation}
  # Weighting:                   #{weighting}
  # Dislosure avoidance:         #{disclosure}
  # Questionnaire design:        #{questionnaire}
  # Series Breaks:               #{series_breaks}
  # Non-response Adjustment:     #{non_response}
  # Seasonal adjustment:         #{seasonal}
  # Statistical Characteristics: #{statistical_characteristics}

  # DOWNLOADS
  # ================================================================
  # Download Format: #{download_format}
  # Download Path:   #{download_path}
  # Download Size:   #{download_size}
  # EOF
  #   end


  # have to make sure to parse links
  def parse_string string=nil
    return unless string
    if string =~ %r{(http://[^ ]+)}
      url = $1
      if url.ends_with?(/[.,;:]/)
        url = url[0..-1]
      end
      string.sub(url, %Q{"#{url}":#{url}}).strip
    else
      string.strip
    end
  end
  
  def ics_description_section output, title, properties
    rows = []
    properties.each_pair do |prop, prop_title|
      val = parse_string(send(prop))
      if val && val.length > 0 && val !~ %r{^N.?A$}
        rows << "* #{prop_title}: #{val}"
      end
    end
    if rows.size > 0
      output += ["h3. #{title}", '']
      output += rows
      output << ''
    end
    output
  end

  def dataset_description
    more_description = []
    more_description = ics_description_section(more_description, "Dataset Summary", { :time_period => "Time Period", :frequency => "Frequency", :category_type => "Data.gov Data Category Type", :category_designation => "Specialized Data Category Designation", :created_at => "Date Released", :updated_at => "Date Updated"})
    more_description = ics_description_section(more_description, "Contributing Agency Information", { :citation => "Citation", :agency_page => "Agency Program Page", :agency_data_series => "Agency Data Series Page"})
    more_description = ics_description_section(more_description, "Miscellaneous Facts", {:fgdc => "FGDC Compliance (Geospatial Only)", :additional_metadata => "Additional Metadata"})
    if more_description.empty?
      [description]      
    else
      [description, '', 'Additional facts from "data.gov":http://data.gov',''] + more_description
    end.join("\n")
  end

  def payload_description
    more_description = []
    more_description = ics_description_section(more_description, "Data Summary", { :collection_mode => "Unit of Analysis", :collection_instrument => "Data Collection Instrument", :variable_list => "Data Dictionary/Variable List", :technical_documentation => "Technical Documentation", :unit => "Unit of Analysis", :granularity => "Granularity", :geo_coverage => "Geographic Coverage", :statistical_methodology => "Statistical Methodology", :sampling => "Sampling", :estimation => "Estimation", :weighting => "Weighting", :disclosure => "Dislosure avoidance", :questionnaire => "Questionnaire design", :series_breaks => "Series Breaks", :non_response => "Non-response Adjustment", :seasonal => "Seasonal adjustment", :statistical_characteristics => "Statistical Characteristics"})
    if more_description.empty?
      []
    else
      ['This is the original data as harvested from "data.gov":http://data.gov',''] + more_description
    end.join("\n")
  end

  def download_size_in_bytes
    return if download_size.nil?
    s = download_size.dup
    s.strip!
    s.downcase!
    s.tr!(' ', '')
    return if s.empty?
    return unless s =~ /[0-9]/

    multiplier = nil
    kb_mult = 1024
    mb_mult = 1048576
    gb_mult = 1073741824
    if s.include?('mb')
      s.sub!('mb','')
      multiplier = mb_mult
    elsif s.include?('m')
      s.sub!('m','')
      multiplier = mb_mult
    elsif s.include?('kb')
      s.sub('kb','')
      multiplier = kb_mult
    elsif s.include?('g')
      s.sub('g','')
      multiplier = gb_mult
    end
    return unless multiplier

    val = s.to_f
    (val * multiplier).to_i
  end

  def valid_payload?
    return false if download_size.nil?
    return false if download_size.strip.empty?
    return false if download_format.nil?    
    true
  end

  def tag_list
    tags = keywords.split(',').map(&:strip).uniq           # split at commas
    tags = tags.map(&:split).flatten.map(&:strip).uniq     # now split at spaces    
    tags = tags.delete_if { |tag| tag =~ /^[A-Z]+$/ }      # get rid of acronyms
    tags = tags.map(&:downcase).uniq                       # downcase
    tags = tags.delete_if { |tag| tag =~ /data/ }          # get rid of data tag
    tags = tags.delete_if { |tag| tag.length < 4 }
    tags
  end

  def dataset_title
    if title =~ /(: | - )/
      parts = title.split($1)
      parts.first
    else
      title
    end
  end

  def dataset_subtitle
    if title =~ /(: | - )/
      parts = title.split($1)
      parts.shift               # throw away title
      sub = parts.join($1).strip
      sub unless sub.empty?
    end
  end
end




