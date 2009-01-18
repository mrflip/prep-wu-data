#!/usr/bin/env ruby

CONFIG = YAML.load(File.open(''))




$progress_count = 0
def track_progress count, record
  $progress_count += 1
  return unless $progress_count % 10_000
  $stderr.puts([Time.now, progress_count, record.to_a].flatten.join("\t"))
end


class ScrapeRequest < Struct.new( :context, :priority, :identifier, :page, :moreinfo, :url, :scraped_at, :contents )
  cattr_accessor :sleep_time
  include TwitterFriends::StructModel::ModelCommon

  def fix_url!
    url = ""
  end


  def self.net_http
    @net_http ||= Net::HTTP.start('www.example.com')
  end

  def get_url!
    Net::HTTP.start(host) do |http|
      req = Net::HTTP::Get.new(url)
      req.basic_auth , 'password'
      response = http.request(req)
      print response.body
    end
    }
  end

  #
  # Get the redirect location... don't follow it, just request and store it.
  #
  def fetch! options={ }
    return unless scraped_at.blank?
    begin
      # look for the redirect
      raw_dest_url = Net::HTTP.get_response(URI.parse(src_url))["location"]
      self.dest_url = self.class.scrub_url(raw_dest_url)
      sleep options[:sleep]
    rescue Exception => e
      nil
    end
    self.scraped_at = TwitterFriends::StructModel::ModelCommon.flatten_date(DateTime.now) if self.scraped_at.blank?
  end

end




REQUEST_FILENAME = 'rawd/scrape_requests/scrape_requests-20080117.tsv'
File.open(REQUEST_FILENAME).each do |line|
  scrape_request_group = ScrapeRequestGroup.new(line.chomp.split("\t"))

  scrape_request_group.each_request do |scrape_request|
    track_progress(progress_count, scrape_request)
    #
    #
    #
    scrape_request.fetch!
    puts scrape_request.output_form
  end
end
