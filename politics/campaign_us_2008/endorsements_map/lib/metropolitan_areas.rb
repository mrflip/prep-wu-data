require File.dirname(__FILE__)+'/hash_of_structs'

class MetropolitanArea < Struct.new(
    :pop_2007, :pop_2000, :pop_rank,
    :pop_chg_pct_00_07, :pop_chg_pct_avg,
    :pop_at_or_above, :pop_aoa_pct,
    :metro_st, :metro_name, :metro_nickname, :csa_name)
  include HashOfStructs
  def self.make_key(metro_name) metro_name     end
  def key()                     metro_name     end
  # #
  # def self.load
  #   puts "Loading #{self.to_s} from cached..."
  #   YAML.load(File.open(ALL_METROS_SAVE_FILENAME))
  # end
  # def self.dump
  #   puts "Dumping #{self.to_s} to cached..."
  #   YAML.dump(@all_metros, File.open(ALL_METROS_SAVE_FILENAME, 'w'))
  # end
  # def self.all_metros
  #   return @all_metros if @all_metros
  #   @all_metros = load()
  # end
  # def self.find_by_name metro_name
  #   all_metros.find{|metro| (metro.metro_name == metro_name) }
  # end
end

class CityMetro < Struct.new(
    :st, :city, :fips_state, :fips_place,
    :cbsa_code, :metro_name, :metro_stature,
    *(MetropolitanArea.members-['metro_name'])
    )
  include HashOfStructs
  def self.make_key(st, city) [st, city]            end
  def key()                   [self.st, self.city]  end

  # METROS_MAPPING_SAVE_FILENAME   = 'fixd/cities_to_metros.yaml'
  # #
  # def self.load
  #   puts "Loading #{self.to_s} from cached..."
  #   YAML.load(File.open(METROS_MAPPING_SAVE_FILENAME))
  # end
  # def self.dump
  #   puts "Dumping #{self.to_s} to cached..."
  #   YAML.dump(@cities_to_metros, File.open(METROS_MAPPING_SAVE_FILENAME, 'w'))
  # end
  # #
  # def self.cities_to_metros
  #   return @cities_to_metros if @cities_to_metros
  #   @cities_to_metros = load()
  # end
  #
  # def self.get(st, city)
  #   self.cities_to_metros[ [st, city] ]
  # end
end
