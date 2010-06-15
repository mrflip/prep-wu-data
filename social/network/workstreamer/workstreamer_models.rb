class JuneCompanyListing
  include DataMapper::Resource
  include DataMapper::LoadsData
  property :object_id, String, :length => 30, :key => true
  property :display_name, String, :length => 255
  property :website, String, :length => 255
  property :facebook_hitid, String, :length => 30, :index => :facebook_hitid
  property :linkedin_hitid, String, :length => 30, :index => :linkedin_hitid
  property :twitter_hitid, String, :length => 30, :index => :twitter_hitid
  property :wikipedia_hitid, String, :length => 30, :index => :wikipedia_hitid
  property :youtube_hitid, String, :length => 30, :index => :youtube_hitid
  property :facebook, String, :length => 255
  property :linkedin, String, :length => 255
  property :twitter, String, :length => 255
  property :wikipedia, String, :length => 255
  property :youtube, String, :length => 255
end

class TurkResult
  include DataMapper::Resource
  include DataMapper::LoadsData
  property :hit_id,        String,      :length => 30,  :index => :hit_id
  property :hit_type,      String,      :length => 30
  property :ass_id,        String,      :length => 30
  property :worker_id,     String,      :length => 30
  property :display_name,  String,      :length => 255, :index => :display_name
  property :in_website,    String,      :length => 255, :index => :biz_site
  property :in_network,    String,      :length => 255
  property :in_net_site,   String,      :length => 255, :index => :biz_site
  property :comment,       Text
  property :a_url,         Text
  property :approve,       String,      :length => 255
  property :reject,        String,      :length => 255
  property :id,            Serial
  property :ass_status,    String,      :length => 255
  property :work_time,     String,      :length => 255
  property :old_hit,       String,      :length => 255
  property :old_hit_type,  String,      :length => 255
  property :old_ass,       String,      :length => 255
  property :old_worker_id, String,      :length => 255
  property :old_time,      String,      :length => 255
  property :in_answer,     String,      :length => 255
  property :sort,          String,      :length => 255
  property :filename,      String,      :length => 255
end

class PartialCompanyListing
  include DataMapper::Resource
  include DataMapper::LoadsData
  property :id,            Serial
  property :md5,           String,      :length => 255
  property :jigsaw_id,     Integer,                      :unique_index => :partialcompany
  property :jigsaw_url,    String,      :length => 255,  :unique_index => :partialcompany
  property :display_name,  String,      :length => 255
  property :num_followers, String,      :length => 255
  property :website,       String,      :length => 255
  property :ticker,        String,      :length => 255
  property :phone,         String,      :length => 255
  property :address_1,     String,      :length => 255
  property :address_2,     String,      :length => 255
  property :city,          String,      :length => 255
  property :state,         String,      :length => 255
  property :zip,           String,      :length => 255
  property :country,       String,      :length => 255
  property :ind_1,         String,      :length => 255
  property :ind_1_sub,     String,      :length => 255
  property :ind_2,         String,      :length => 255
  property :ind_2_sub,     String,      :length => 255
  property :ind_3,         String,      :length => 255
  property :ind_3_sub,     String,      :length => 255
  property :sic,           String
  property :employees,     String,      :length => 255
  property :employees_rg,  String,      :length => 255
  property :revenue,       String,      :length => 255
  property :revenue_rg,    String,      :length => 255
  property :ownership,     String,      :length => 255
  property :ticker,        String,      :length => 255
  property :n_contacts,    String,      :length => 255
  property :jigsaw_url,    String,      :length => 255
  property :linkedin,      String,      :length => 255
  property :wikipedia,     String,      :length => 255
  property :yg_finance,    String,      :length => 255
  property :manta,         String,      :length => 255
  property :zoominfo,      String,      :length => 255
  property :twitter_all,   Text
  property :blog,          String,      :length => 255
  property :facebook,      Text
  property :flickr,        String,      :length => 255
  property :youtube,       Text
  property :scribd,        String,      :length => 255
  property :delicious,     String,      :length => 255
  property :filename,      String,      :length => 255,  :unique_index => :partialcompany
end

class FinalCompanyListing
  include DataMapper::Resource
  include DataMapper::LoadsData
  property :id,            Serial
  property :md5,           String,      :length => 255
  property :jigsaw_id,     Integer,                      :unique_index => :finalcompany
  property :jigsaw_url,    String,      :length => 255,  :unique_index => :finalcompany
  property :display_name,  String,      :length => 255
  property :num_followers, String,      :length => 255
  property :website,       String,      :length => 255
  property :ticker,        String,      :length => 255
  property :phone,         String,      :length => 255
  property :address_1,     String,      :length => 255
  property :address_2,     String,      :length => 255
  property :city,          String,      :length => 255
  property :state,         String,      :length => 255
  property :zip,           String,      :length => 255
  property :country,       String,      :length => 255
  property :ind_1,         String,      :length => 255
  property :ind_1_sub,     String,      :length => 255
  property :ind_2,         String,      :length => 255
  property :ind_2_sub,     String,      :length => 255
  property :ind_3,         String,      :length => 255
  property :ind_3_sub,     String,      :length => 255
  property :sic,           String
  property :employees,     String,      :length => 255
  property :employees_rg,  String,      :length => 255
  property :revenue,       String,      :length => 255
  property :revenue_rg,    String,      :length => 255
  property :ownership,     String,      :length => 255
  property :ticker,        String,      :length => 255
  property :n_contacts,    String,      :length => 255
  property :jigsaw_url,    String,      :length => 255
  property :linkedin,      String,      :length => 255
  property :wikipedia,     String,      :length => 255
  property :yg_finance,    String,      :length => 255
  property :manta,         String,      :length => 255
  property :zoominfo,      String,      :length => 255
  property :twitter_all,   Text
  property :blog,          String,      :length => 255
  property :facebook,      Text
  property :flickr,        String,      :length => 255
  property :youtube,       Text
  property :scribd,        String,      :length => 255
  property :delicious,     String,      :length => 255
  property :filename,      String,      :length => 255,  :unique_index => :finalcompany
end

