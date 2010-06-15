#!/usr/bin/env ruby
require 'rubygems'
require './standard_datamapper_setup'
DataMapper.setup_db_connection 'imw_workstreamer'
WORK_DIR = File.dirname(__FILE__)+'/work'
require './workstreamer_models'

# TurkResult.auto_migrate!
TURK_RESULT_FILES = {
  # all turk_result cols:     hit_id hit_type ass_id worker_id work_time old_hit old_hit_type old_ass old_worker_id old_time display_name in_website in_network in_net_site in_answer comment  a_url   approve reject sort  ass_status
  "twitter-p1-1"        => %w[hit_id hit_type ass_id worker_id                                                               display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "twitter-p2-2"        => %w[hit_id hit_type ass_id worker_id work_time old_hit old_hit_type old_ass old_worker_id          display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "facebook-p1-2"       => %w[hit_id hit_type ass_id worker_id work_time                                                     display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "facebook-p2-1"       => %w[hit_id hit_type ass_id worker_id                                                               display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "facebook-p2-2"       => %w[hit_id hit_type ass_id worker_id work_time old_hit old_hit_type old_ass old_worker_id          display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "facebook-q-1"        => %w[hit_id hit_type ass_id worker_id                                                               display_name in_website in_network in_net_site           comment  a_url   approve reject sort ],
  "youtube-p1-1"        => %w[hit_id hit_type ass_id worker_id ass_status work_time                                          display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "youtube-p1-2"        => %w[hit_id hit_type ass_id worker_id work_time                                                     display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "youtube-p1-200"      => %w[hit_id hit_type ass_id worker_id work_time old_hit old_hit_type old_ass old_worker_id old_time display_name in_website in_network in_net_site in_answer comment  a_url   approve reject ],
  "youtube-p2-1"        => %w[hit_id hit_type ass_id worker_id work_time                                                     display_name in_website in_network in_net_site           comment  a_url   approve reject ],
  "youtube-p2-3"        => %w[hit_id hit_type ass_id worker_id work_time old_hit old_hit_type old_ass old_worker_id old_time display_name in_website in_network in_net_site           comment  a_url   approve reject ],
}
TURK_RESULT_FILES.each do |filename, columns|
  TurkResult.load_data_infile(WORK_DIR+"/to_process/#{filename}.csv", columns)
end

# CompanyListing.auto_migrate!
# COMPANY_LISTING_FILES = {
#   "li_tw_wp-p1-1"       => %w[md5 jigsaw_id jigsaw_url display_name num_followers website ticker phone address_1 address_2 city state zip country linkedin wikipedia yg_finance manta zoominfo twitter_all ],
#   "popular_companies"   => %w[md5 jigsaw_id jigsaw_url display_name               website ticker phone address_1 address_2 city state zip country linkedin wikipedia  ],
#   "fortune"             => %w[    jigsaw_id            display_name               website        phone address_1           city state zip country ind_1 ind_1_sub ind_2 ind_2_sub ind_3 ind_3_sub sic employees employees_rg revenue revenue_rg ownership ticker n_contacts jigsaw_url
#                                                                                                                                                   linkedin wikipedia yg_finance manta zoominfo twitter_all blog facebook flickr youtube scribd delicious ],
# }
# COMPANY_LISTING_FILES.each do |filename, columns|
#   CompanyListing.load_data_infile(WORK_DIR+"/to_process/#{filename}.csv", columns)
# end
