require 'rubygems'
require 'imw'

IMW.add_path(:ripd,     "ripd")
IMW.add_path(:listings, :ripd, "listings")

# The dataset listing pages at data.gov can be made to show 100
# datasets per page via the following url
def dataset_listing_page_url num
  "http://www.data.gov/catalog/raw/category/0/agency/0/filter//type//sort//page/#{num}/count/100#data"
end

# There are 8 total pages at 100 datasets/page
def get_dataset_listing_pages
  FileUtils.mkdir_p(IMW.path_to(:listings))
  (1..8).each do |page_num|
    url  = dataset_listing_page_url(page_num)
    path = IMW.path_to(:listings, "datasets.page-#{page_num}.html")
    IMW.open(url).cp IMW.path_to(path)
    puts "#{url} => #{path}"
  end
end

if $0 == __FILE__
  get_dataset_listing_pages
end




