

DATE_SENTRIES = ['DATE_GOES_HERE', 'DATE_WENT_THERE']
.gsub(/<!-- #{sentry1} -->.*?<!-- #{sentry1} -->/, filler)

#
# Create the table of endorsements
#
def td el, width=0, html_class=nil, style=nil
  html_class = html_class ? " class='#{html_class}'" : ''
  style      = style      ? " style='#{html_class}'" : ''
  "%-#{width+9+html_class.length}s" % ["<td#{html_class}>#{el}</td>"]
end
def pct(num) number_to_percentage(100*num, :precision => 0) end
def table_row e
  if (e.metro && e.metro.metro_stature == 'MSA')
    metro_pop, metro_poprank =  e.metro.values_of(:pop_2007, :pop_rank)
    # short_name = e.metro.metro_nickname
    short_name = e.metro.metro_name.gsub(/([^,-]+)(?:[^,]*), (\w\w).*$/, '\1')
    metro_name = "%s (%s)" % [short_name, e.metro.metro_st]
    penetration = pct(e.circ.to_f / metro_pop)
  else
    metro_name, metro_pop, metro_poprank, penetration = []
  end
  '    <tr>' + [
    (e.rank == 0 ? td('-', 3) : td(e.rank, 3)),
    td(e.paper,35), td(e.circ_as_text, 9),
    td(metro_name, 30, :hid), td(metro_pop, 6, :hid), td(penetration, 5, :hid),
    td(metro_poprank, 3, :poprk),
    td(e.city_st, 40),
    td(e.prez04, 6, e.prez04_color), td(e.prez, 6, e.prez_color),
    td("%6.1f"%e.lat, 6, :lat), td("%6.1f"%e.lng, 6, :lng),
  ].join('') + "</tr>\n"
end

#
# Bin all newspapers by their endorsed status
#
endorsement_bins = {
  nil => {:papers => [], :total_circ => 0, :title => 'Top 100 papers (by circulation) that have not yet endorsed a candidate', },
   -3 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. McCain (and endorsed Kerry in 2004)', },
   -2 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. McCain (no endorsement in 2004)',     },
   -1 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. McCain (and endorsed Bush or none in 2004)',  },
    3 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. Obama (endorsed Bush in 2004)', },
    2 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. Obama (no endorsement in 2004)',     },
    1 => {:papers => [], :total_circ => 0, :title => 'Endorsing Sen. Obama (endorsed Kerry or none in 2004)',  },
}
endorsements.sort_by{|paper, e| [-e.circ.to_i, e[:st], e[:paper].gsub(/^The /,'')]}.each do |paper, e|
  bin = case e.movement when -2 then -1 when 2 then 1 else e.movement end
  if (!e.st) || (!e.lat) then p e  end
  endorsement_bins[bin][:papers]     << e
  endorsement_bins[bin][:total_circ] += e.circ_with_split
  #
  #
  find_prez04_from_wikipedia(e)
end
#
# Dump HTML for endorsement status
#
endorsement_table = ''
[3, 1, -1, -3, nil].each do |bin|
  vals = endorsement_bins[bin]
  endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>#{vals[:title]}: #{vals[:papers].length} papers, #{as_millions(vals[:total_circ])} total circulation</th></tr>"
  vals[:papers].each do |endorsement|
    endorsement_table << table_row(endorsement)
  end
  if (vals[:papers] == [])
    endorsement_table << '<tr><td colspan="8" style="text-align:center"><em>(none yet)</em></td></tr>'
  end
end
#
# # Top 100 papers by metro
# endorsement_table << "  <tr><th colspan='8' scope='colgroup' class='chunk'>Top 100 papers w/ Metro pop</th></tr>"
# #reject{|paper, e| e.rank == 0 }.
# endorsements.find_all{|paper, e| e.metro && e.metro.pop_rank }.sort_by{|paper, e| [e.metro.pop_rank, e.all_rank]}.each do |paper, e|
#   endorsement_table << table_row(e)
# end
