require 'color'; require 'color/hsl' ; require 'color/css'

#
# Election Return class
#
class ElectionReturn < Struct.new(:st, :total, :bush, :kerry, :nader,
    :total_precincts, :precincts_reporting, :county, :geo)
  def initialize *args
    super *args
    [:total, :bush, :kerry, :nader, :total_precincts, :precincts_reporting
    ].each{|attr| (self[attr] ? (self[attr] = self[attr].gsub(/,/, '').to_i) : 0) }
    self.st = self.st.upcase
    self.total = (bush+kerry+nader)
  end
  def self.load(tsv_filename)
    ers = []
    FasterCSV.foreach(path_to(:fixd, tsv_filename), :col_sep => "\t") do |row|
      ers << ElectionReturn.new(*row)
    end
    ers[1..-1].reject{|er| er.total == 0 }
  end

  #
  #
  #
  def blue_margin
    #puts self.to_json if total == 0
    (kerry - bush).to_f / total.to_f
  end
  def margin(cand)
    self[cand].to_f     / total.to_f
  end

  #
  # at max, hsl(2/3.0, 1, 1) => hsl(1.0, 1, 1)
  #
  def interp(v1, v2, t)
    v1 + t*(v2-v1)
  end
  def color
    hue = interp( 1.0, 2.0/3.0, (blue_margin+1.2)/2   )
    sat = interp( 0.2,     1.0,  blue_margin.abs )
    #puts [hue, sat, blue_margin].to_json
    c = Color::HSL.from_fraction(hue, sat, 0.7).html
    # puts c
    c
  end

end


