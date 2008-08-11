require 'imw/dataset/datamapper'
require 'imw/dataset/file_collection'

#DataMapper::Logger.new(STDOUT, :debug)
IMW::DataSet.setup_remote_connection IMW::DEFAULT_DATABASE_CONNECTION_PARAMS.merge({ :dbname => 'imw_weather_ncdc' })

#
# index the raw files retrieved from website
#
class WeatherRippedFile
  include DataMapper::Resource
  property      :usaf,                  Integer,   :key      => true
  property      :wban,                  Integer,   :key      => true
  property      :year,                  Integer,   :key      => true
  belongs_to    :ripped_file
end
