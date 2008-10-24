#
PLACE_TYPE_RE = /\s+(County|Parish|Municipio|Borough|city|Census Area|Municipality)$/
class County < Struct.new(:st, :name,
    :pop, :housing_units,
    :area, :water_area, :land_area,
    :pop_density, :house_density, :root_name, :place_type)
  cattr_accessor :place_types
  self.place_types = { }
  def initialize *args
    super *args
    [:pop, :housing_units,
    ].each{|attr| (self[attr] ? (self[attr] = self[attr].gsub(/,/, '').to_f) : 0) }
    [:area, :water_area, :land_area, :pop_density, :house_density
    ].each{|attr| (self[attr] ? (self[attr] = self[attr].gsub(/,/, '').to_f) : 0) }
    set_root_name
  end
  def set_root_name
    case
    when (name == st)
      self.place_type = 'State'
      self.root_name  = name
    when (name == 'District of Columbia')
      self.place_type = name
      self.root_name  = name
    when (name == 'Carson City')
      self.place_type = 'city'
      self.root_name  = name
    when (name =~ /^(?:Baltimore|St\. Louis|Bedford|Fairfax|Franklin|Richmond|Roanoke)( city)$/)
      self.place_type = $2
      self.root_name  = name.gsub(/ city$/, ' City')
    when PLACE_TYPE_RE.match(name)
      self.place_type = $1
      self.root_name  = name.gsub(PLACE_TYPE_RE, '')
    else
      puts self
    end
    self.class.place_types[place_type]||=0; self.class.place_types[place_type] += 1
  end
end
