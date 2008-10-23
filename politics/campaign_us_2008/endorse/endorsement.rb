
MOVEMENT_FROM           = { 'B'  => -1, ''   => 0, 'N/A' => 0, 'K' => 1, 'N' => 1 }
MOVEMENT_TO             = { 'McCain' => -2, 'Obama' => 2, }
PREZ04                  = { 'B'  => 'Bush', ''   => '', 'N/A' => '(none)', 'K' => 'Kerry', 'N' => '(none)' }
SPLIT_ENDORSEMENTS      =  ['Las Vegas Sun', 'Las Vegas Review-Journal', 'The Chattanooga Free Press', 'Chattanooga Times']
class Endorsement < Struct.new(
  :prez, :prev, :rank, :circ, :daily, :sun, :lat, :lng, :st, :city, :paper,
  :movement, :prez04 # don't set these -- will be set from other attrs
  )
  def initialize(*args)
    super *args
    # fix attributes
    fix_movement
    fix_lat_lng_overlap
    self.prez04 = PREZ04[prev]
  end
  #
  # score the endorsement: 1 point for d=>d, 2 for none => d, 3 for r => d
  # (and similarly for * => r)
  #
  def fix_movement
    if prez == ''
      self.movement = nil
    else
      self.movement = MOVEMENT_TO[prez] - MOVEMENT_FROM[prev]
    end
  end
  #
  # offset abutting cities
  #
  def fix_lat_lng_overlap
    return unless lat && lng
    shifts = {
      'Chicago Sun-Times' =>  0.4, 'Chicago Tribune'    => -0.2, 'Southwest News-Herald' =>  0.1,
      'The Seattle Times' => -0.2, 'The Capital Times'  => -0.2,
      'New York Post'     =>  0.4, 'The Daily News'     => -0.2,
      'el Diario'         =>  0.1, 'Yamhill Valley News-Register' =>  0.1,
      'La Opinion'        =>  0.3, 'Los Angeles Daily News'     =>  -0.4,
      'Las Vegas Sun'     => -0.2, 'Las Vegas Review-Journal' => 0.2,
      'Chattanooga Times' => -0.2, 'The Chattanooga Free Press' => 0.2,
    }
    if (lng_shift = shifts[paper])
      self.lng += lng_shift
    end
    if (city  == 'Honolulu')
      self.lng, self.lat = ll_from_xy(279, 564-466)
    end
    self.lat = (lat*100).round()/100.0
    self.lng = (lng*100).round()/100.0
  end
  #
  # fix papers with split endorsements (two editorial boards)
  def split_endorsement
    SPLIT_ENDORSEMENTS.include?(paper)
  end
  def circ_with_split
    split_endorsement ? circ/2 : circ
  end
  def circ_as_text
    case
    when circ == 0         then 'unknown'
    when split_endorsement then "#{circ}/2 (see <a href='#wtftwoendorsements'>note #2)</a>"
    else                        circ
    end
  end
end
