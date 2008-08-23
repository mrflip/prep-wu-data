require 'imw/dataset/datamapper'
# DataMapper::Logger.new(STDOUT, :debug)
db_params = IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_sport_baseball' })
IMW::DataSet.setup_remote_connection db_params

#
# index the raw files retrieved from website
#
class Park
  include DataMapper::Resource
  property      :id,                    String,         :length => 5,        :key => true
  property      :beg_date,              Date
  property      :end_date,              Date
  property      :num_games,             Integer
  property      :name,                  String

  # property      :streetaddr,            String
  property      :extaddr,               String
  property      :city,                  String
  property      :state,                 String,         :length => 2
  property      :country,               String,         :length => 2
  property      :zip,                   String,         :length => 10
  property      :tel,                   String,         :length => 18
  property      :is_current,            Boolean
  property      :lat,                   Float
  property      :lng,                   Float
  property      :url,                   String
  property      :spanishurl,            String
  property      :logofile,              String

  has n,        :park_teams
  has n,        :teams,         :through => :park_teams
  has n,        :other_names,   :class_name => 'ParkOtherName'
  has n,        :comments,      :class_name => 'ParkComment'
end

Park.property 'streetaddr'.to_sym, String


#
# The tenancy of a team in each park
#
class ParkTeam
  include DataMapper::Resource
  property      :team_id,               String,         :length => 5,   :key => true
  property      :park_id,               String,         :length => 5,   :key => true
  property      :beg_date,              Date
  property      :end_date,              Date
  property      :num_games,             Integer
  property      :neutralsite,           Boolean
  property      :parkname_bdb,          String
  belongs_to    :park
  belongs_to    :team
end

#
# Stripped down.
#
class Team
  include DataMapper::Resource
  property      :id,                    String,         :length => 5,   :key => true
  property      :name,                  String
  has n,        :park_teams
  has n,        :parks, :through => :park_teams
end

class ParkOtherName
  include DataMapper::Resource
  property      :id,                    Integer,                        :serial => true
  property      :park_id,               String,         :length => 5
  property      :name,                  String
  property      :beg_year,              Integer
  property      :end_year,              Integer
  property      :is_official,           Boolean
  property      :is_current,            Boolean
end

class ParkComment
  include DataMapper::Resource
  property      :id,                    Integer,                        :serial => true
  property      :park_id,               String,         :length => 5,   :key => true
  property      :comment,               Text
  belongs_to    :park
end

#
# Wipe DB and add new migration
#
DataMapper.auto_migrate!
