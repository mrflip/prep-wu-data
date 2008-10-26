#!/usr/bin/env ruby
require 'rubygems'
require 'imw/utils/extensions/core'
require 'yaml'
require 'open-uri'
require 'xmlsimple'

def fetch_landmark_pts
  f = open('http://maps.google.com/maps/ms?ie=UTF8&hl=en&msa=0&output=georss&msid=105061950211387493656.000459916132d60653b8f')
  coords = XmlSimple.xml_in(f)
  points = coords['channel'][0]['item'].map{|i| [i['title'][0].strip, i['point'][0].strip] }
  landmark_pts = { }
  points.each do |name, coord|
    lat, lng = /\s*([\-\d\.]+)\s+([\-\d\.]+)/.match(coord).captures.map(&:to_f)
    landmark_pts[name] = [lat, lng]
  end
end

LANDMARK_PTS = {
  "Maine, NE Tip"               => [47.355572,  -68.296509],
  "Washington, NW Indented Tip" => [48.994637, -123.321533],
  "Denver"                      => [39.749435, -104.996338],
  "US, SW Tip"                  => [32.523659, -117.13623 ],
  "Texas, Southern Tip"         => [25.841921,  -97.396545],
  "Chicago"                     => [41.86956,   -87.626953],
  "Florida, Southern Gulf Tip"  => [25.112959,  -81.087341]
}

IMG_PTS = {
  "Maine, NE Tip"               => [1314,  92],
  "Florida, Southern Gulf Tip"  => [1023, 727],
  "Texas, Southern Tip"         => [ 651, 710],
  "US, SW Tip"                  => [ 203, 536],
  "Washington, NW Indented Tip" => [  62,  37],
  "Denver"                      => [ 479, 331],
  "Chicago"                     => [ 874, 267],
  "TR"                          => [1000, 564],
  "BL"                          => [0,    0],
}

# img_pts.each do |k,v|
#   puts "%6d\t%6d\t%10.5f\t%10.5f\t%s" % (v + (landmark_pts[k]||[-1,-1]) + [k])
# end

def xy_from_ll lat, lng
  [
            ( 22.75 * lng) + 2867.97,
    758 - ( (-28.89 * lat) + 1452.57),
  ]
end

def ll_from_xy x, y
  [
    (x         - 2118) /  16.8,
    ((564 - y) - 1081) / -21.5,
  ]
end

def fake_points
  tr_x, tr_y = ll_from_xy(1000,534)
  bl_x, bl_y = ll_from_xy(0,   0)
  LANDMARK_PTS.map{|name, ll|
    {'x'=> ll[1], 'y' => ll[0], 'value' => 50, 'content' => "#{name}: #{'%6.2f'%ll[1]} : #{'%6.2f'%ll[0]}", 'bullet_color' => "44ff44" }
  } + [
    {'x'=> bl_x, 'y' => bl_y, 'value' => 100, 'content' => "BL: #{'%6.2f'%bl_y} : #{'%6.2f'%bl_x}", 'bullet_color' => "00ff00" },
    {'x'=> tr_x, 'y' => tr_y, 'value' => 100, 'content' => "TR: #{'%6.2f'%tr_y} : #{'%6.2f'%tr_x}", 'bullet_color' => "00ff00" }
  ]

end
