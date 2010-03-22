require File.dirname(__FILE__) + "/get_dataset_listing_pages"

IMW.add_path(:rawd, "rawd")
IMW.add_path(:dataset_pages, :rawd, "dataset_pages")

def extract_dataset_ids_from_listings_path path
  IMW.open(path).parse(:dataset_urls => IMW::HTMLParserMatcher::MatchArray.new("div.name", IMW::HTMLParserMatcher::MatchAttribute.new("a", "href"), :html => true))[:dataset_urls].map do |rel_path|
    File.basename(rel_path).to_i
  end
end

def extract_dataset_ids
  Dir[IMW.path_to(:listings) + "/*.html"].map { |path| extract_dataset_ids_from_listings_path(path) }.flatten.sort
end

def get_dataset_pages
  FileUtils.mkdir_p IMW.path_to(:dataset_pages)
  extract_dataset_ids.each do |id|
    url  = "http://data.gov/details/#{id}"
    path = IMW.path_to(:dataset_pages, "#{id}.html")
    IMW.open(url).cp(path)
    puts "#{url} => #{path}"
  end
end

if $0 == __FILE__
  get_dataset_pages
end



