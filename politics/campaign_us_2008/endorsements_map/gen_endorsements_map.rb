
#
# XML-able hash for amcharts point
#
def point_for_graph endorsement, content=nil
  hsh = { }
  hsh['content'] = content || popup_text(endorsement)
  hsh['x'], hsh['y'] = [ endorsement[:lng], endorsement[:lat] ]
  hsh['value'] = Math.sqrt(endorsement.circ_with_split)
  # Bullet Appearance
  hsh['bullet_color'] = {
    -3 => 'ff1111', -2 => 'cc7777', -1 => 'cc7777', nil => '888888',
     3 => '1111ff',  2 => '7777cc',  1 => '7777cc',             }[endorsement[:movement]]
  hsh['bullet_alpha'] = {
    -3 => 60, -2 => 60, -1 => 60, nil => 15,
     3 => 60,  2 => 60,  1  => 60,                              }[endorsement[:movement]]
  hsh['bullet'] = {
    -3 => 'round_outline', -2 => 'bubble', -1 => 'bubble', nil => 'round',
     3 => 'round_outline',  2 => 'bubble',  1 => 'bubble',      }[endorsement[:movement]]
  hsh.each{|k,v| puts "Unset value for #{k} in #{hsh['content']}" unless v; }
  hsh
end
#
# Readable text for the popup balloon
#
def popup_text endorsement
  prez   = endorsement.prez_as_text
  circ   = endorsement.circ_as_text
  rank   = (endorsement.rank==0) ? '' : " (##{endorsement.rank})"
  prez04 = endorsement.prez04 == '' ? '--' : endorsement.prez04
  "%s <br />%s, %s<br />2008: %s 2004: %s<br />circulation %s%s" % (endorsement.values_of(:paper, :city, :st)+[prez, prez04, circ, rank])
end
#
# XML-able hash for whole amcharts graph
#
def hash_for_graph endorsements, endorsement_bins
  endorsements = endorsements.values.sort_by{|e| -e.circ_with_split } # must be by circ so bubbles don't get buried
  hsh = { 'chart' => { 'graphs' => { 'graph' => [
          # points
          { 'gid' => 0, 'point' =>
            endorsements.map{|e| point_for_graph(e)} +  # .reject{|e| e.prez == ''}
            # fake_points +
            [ { 'x' => -71.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 }, ] # sets the max size
          },
          { 'gid' => 1, 'title' => 'Endorsement Legend', 'point' => summary_points(endorsements, endorsement_bins)},
          { 'gid' => 2, 'title' => 'Circulation Legend', 'point' => [
              { 'x' =>  -50.0, 'y' => ll_from_xy(40, 100 - 7)[1], 'value' => Math.sqrt(2_100_000), 'bullet_alpha' => 0 },
              # { 'x' => -118.4, 'y' => 33.93,                      'value' => Math.sqrt(  773_884), 'content' => 'Circulation 250,000', 'bullet' => 'square' },
              { 'x' => ll_from_xy(1000-80,  0)[0], 'y' => ll_from_xy(0, 198 - 7)[1], 'value' => Math.sqrt(  500_000), 'content' => '500k' },
              { 'x' => ll_from_xy(1000-80,  0)[0], 'y' => ll_from_xy(0, 175 - 7)[1], 'value' => Math.sqrt(   50_000), 'content' => '50k' },
          ]}
        ]}}}
  XmlSimple.xml_out hsh, 'KeepRoot' => true
end
#
# Generate AMCharts graph
#
def dump_hash_for_graph endorsements, graph_xml_filename, endorsement_bins
  puts "Writing to graph file #{graph_xml_filename}"
  File.open(graph_xml_filename, 'w') do |graph_xml_out|
    graph_xml_out << hash_for_graph(endorsements, endorsement_bins)
  end
end


#
#
#
def as_millions(f) '%3.1f'%[ f / 1_000_000.0] + 'M' end
def summary_points endorsements, endorsement_bins
  legend_points = []
  yval_for_mv = { 'O' => 122, 3=>100, 1 => 80, 'M' => 57, -1 => 35, -3 => 15 };
  xval = 150
  prez_for_mv = { 3=>'Obama', 1 => 'Obama',      -1 => 'McCain',    -3 => 'McCain' };
  prev_for_mv = { 3=>'Bush',  1 => 'Kerry or none', -1 => 'Bush or none', -3 => 'Kerry' };
  #
  tot_p = { }; tot_c = { }; [-3, -1, 1, 3].each do |mv|
    tot_p[mv] = endorsement_bins[mv][:papers].length; tot_c[mv] = endorsement_bins[mv][:total_circ]
  end
  [3, 1, -1, -3].each do |mv|
    lng, lat = ll_from_xy(1000-xval, yval_for_mv[mv])
    legend_popup  = "Now endorsing %s,<br/>endorsed %s in 2004<br/>%s papers, ~%s circ."% [prez_for_mv[mv], prev_for_mv[mv], tot_p[mv], as_millions(tot_c[mv]), ]
    e = Endorsement.new('','','',7500,0,0,lat,lng,'','','',''); e.movement = mv
    legend_points << point_for_graph(e, legend_popup ).merge({ 'bullet_alpha' => 70 })
    label_text    = "%s in '04"% [ prev_for_mv[mv] ]
    puts "<label> <x>!#{xval-19}</x> <y>!#{yval_for_mv[mv]+5}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end
  [ ['O', "%s (%s/~%s tot)"% ['Obama',  tot_p[ 3] + tot_p[ 1], as_millions(tot_c[ 3]+tot_c[ 1]) ]],
    ['M', "%s (%s/~%s tot)"% ['McCain', tot_p[-3] + tot_p[-1], as_millions(tot_c[-3]+tot_c[-1]) ]],
  ].each do |mv, label_text|
    puts "<label> <x>!#{xval+5}</x> <y>!#{yval_for_mv[mv]}</y> <text>#{label_text}</text> <align>left</align> <text_size>13</text_size> <text_color>444444</text_color> </label>"
  end
  legend_points
end


  # #
  # # offset abutting cities
  # #
  # def fix_lat_lng_overlap
  #   return unless lat && lng
  #   lngshifts = {
  #     'Chicago Sun-Times' =>  0.4, 'Chicago Tribune'    => -0.2, 'Southwest News-Herald' =>  0.1,
  #     'The Seattle Times' => -0.2, 'The Capital Times'  => -0.2,
  #     'New York Post'     =>  0.4, 'The Daily News'     => -0.2, 'The New York Times' => 0.8,
  #     'The Wall Street Journal' => 1,
  #     'el Diario'         =>  0.1, 'Yamhill Valley News-Register' =>  0.1,
  #     'La Opinion'        =>  0.3, 'Los Angeles Daily News'     =>  -0.4,
  #     'Las Vegas Sun'     => -0.2, 'Las Vegas Review-Journal' => 0.2,
  #     'Chattanooga Times' => -0.2, 'The Chattanooga Free Press' => 0.2,
  #   }
  #   latshifts = {
  #     'The New York Times' => -0.4,
  #     'The Wall Street Journal' => -0.4,
  #   }
  #   if (lng_shift = lngshifts[paper]) then self.lng += lng_shift end
  #   if (lat_shift = latshifts[paper]) then self.lat += lat_shift end
  #   if (city  == 'Honolulu')
  #     self.lng, self.lat = ll_from_xy(279, 564-466)
  #   end
  #   self.lat = (lat*100).round()/100.0
  #   self.lng = (lng*100).round()/100.0
  # end
