class CityMetro < Struct.new(:st, :metro_city, :city, :cbsa_code, :fips_state, :fips_place, :metro_st, :metro_stature)
  METROS_MAPPING_SAVE_FILENAME   = 'fixd/metros_mapping.yaml'
  #
  def self.load
    YAML.load(File.open(METROS_MAPPING_SAVE_FILENAME))
  end
  def self.dump
    YAML.dump(@cities_to_metros, File.open(METROS_MAPPING_SAVE_FILENAME, 'w'))
  end
  #
  def self.cities_to_metros
    return @cities_to_metros if @cities_to_metros
    @cities_to_metros = load()
  end
  
  def self.get(st, city)
    self.cities_to_metros[ [st, city] ]
  end
end

