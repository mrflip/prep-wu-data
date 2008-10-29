require File.dirname(__FILE__)+'/hash_of_structs'

PARTY_ALIGNMENT = {
  'GHW Bush'  => -1, 'Dole'  => -1, 'Bush'  => -1, 'McCain' => -1,
  'Clinton'   =>  1, 'Gore'  =>  1, 'Kerry' =>  1, 'Obama'  =>  1,
  nil         =>  0, ''      =>  0, 'N/A'   =>  0, 'N'      =>  0 }
PREZ_CODE       = {
  'GHW Bush'  => 'HW', 'Dole' => 'D', 'Bush' => 'W',  'McCain' => 'M',
  'Clinton'   => 'C',  'Gore' => 'G', 'Kerry' => 'K', 'Obama'  => 'O',
  nil         =>  0, ''      =>  0
}
MOVEMENT_TO             = { 'McCain' => -2, 'Obama' => 2, }
SPLIT_ENDORSEMENTS      =  ['Las Vegas Sun', 'Las Vegas Review-Journal', 'The Chattanooga Free Press', 'Chattanooga Times']
class Endorsement < Struct.new(
  :prez_2008, :prez_2004, :prez_2000, :prez_1996, :prez_1992,
    :rank, :circ, :daily, :sun, :lat, :lng, :st, :city, :paper,
    :metro, :tmp
  )
  include HashOfStructs
  def self.make_key(paper) paper       end
  def key()                self.paper  end

  def initialize(*args)
    super *args
  end

  # fix attributes
  def fix!
    [:circ, :daily, :sun, :rank].each{|attr| self[attr] = self[attr].to_i if self[attr] }
    [:lat, :lng                ].each{|attr| self[attr] = self[attr].to_f if self[attr] }
  end

  #
  # Sortable attributes
  #
  def self.sort_by_st_city_paper()  all.sort_by{|pp, e| [ e.st||'', e.city||'', e.paper||'', ]}           end
  def self.sort_by_circ()           all.sort_by{|pp, e| [ (e.circ||0), e.st||'', e.city||'', e.paper||'', ]}  end
  def self.sort_by_nprezzes()       all.sort_by{|pp, e| [ e.prez.values.compact.length, (e.circ||0), e.st||'', e.city||'', e.paper||'', ]}  end

  #

  #
  #
  #
  def prez
    Hash.zip [2008, 2004, 2000, 1996, 1992], self.values_of(:prez_2008, :prez_2004, :prez_2000, :prez_1996, :prez_1992)
  end
  def self.set_prez hsh, yr, prez
    hsh["prez_#{yr}".to_sym] = prez
  end
  #
  # score the endorsement: 1 point for d=>d, 2 for none => d, 3 for r => d
  # (and similarly for * => r)
  #
  def movement yr1, yr2
    from, to = [party_in(yr1), party_in(yr1)]
    (from && to) ? (to - from) : nil
  end
  def party dood
    PARTY_ALIGNMENT[dood]
  end
  def party_in yr
    party prez[yr]
  end
  def prez_as_text yr
     (prez[yr].blank?) ? '(none yet)' : prez[yr]
  end

  #
  # fix papers with split endorsements (two editorial boards)
  #
  def split_endorsement
    SPLIT_ENDORSEMENTS.include?(paper)
  end
  def circ_with_split
    split_endorsement ? circ/2 : circ
  end

  #
  # attrs as text
  #
  def circ_as_text
    case
    when circ == 0         then 'unknown'
    when split_endorsement then "#{circ}/2 - see <a href='#wtftwoendorsements'>note #2</a>"
    else                        circ.to_s
    end
  end
  def city_st
    (paper == 'USA Today') ? "[national]" : "#{city}, #{st}"
  end
  def endorsed_years
    prez.sort.map{|k, v| k if v }
  end
  def endorsement_hist
    endorsed_years.map{|yr| [yr, PREZ_CODE[prez[yr]]] }
  end
  def endorsement_hist_str
    endorsement_hist.map{|yr, pr| yr ? ("%4s:%-2s"%[yr,pr]) : ' '*7 }.join(" ")
  end
  #
  # Color code for table
  #
  def self.party_color candidate
    case candidate
    when 'Obama', 'Kerry', 'Gore', 'Clinton'    then 'blue'
    when 'Bush', 'McCain', 'Dole'               then 'red'
    when 'N', '(none)'                          then 'gray'
    when ''                                     then 'none'
    else
      raise "Haven't met candidate #{candidate}"
    end
  end
  def prez_color(yr) self.class.party_color(prez[yr]) end
end
