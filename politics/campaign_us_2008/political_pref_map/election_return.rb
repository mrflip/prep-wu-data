
#
# Election Return class
#
class ElectionReturn < Struct.new(:st, :total, :bush, :kerry, :nader, :total_precincts, :precincts_reporting, :county)
  def initialize *args
    super *args
    [:total, :bush, :kerry, :nader, :total_precincts, :precincts_reporting
    ].each{|attr| (self[attr] ? (self[attr] = self[attr].gsub(/,/, '').to_i) : 0) }
    self.total = (bush+kerry+nader)
  end
  def self.from_hash(hsh)
    self.new *hsh.values_at(*self.members.map(&:to_sym))
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
    puts self.to_json if total == 0
    (kerry - bush).to_f / total.to_f
  end
  def margin(cand)
    self[cand].to_f     / total.to_f
  end

end


