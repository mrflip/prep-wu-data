
# LOAD DATA LOCAL INFILE '/Applications/MAMP/tmp/php/phpe2aGBy' INTO TABLE `Parks` FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n'# Affected rows: 256

# -- cities check out OK
# SELECT * FROM Parks P WHERE city != city_pc OR state != state_pc
# -- dates
# SELECT * FROM Parks P WHERE beg_rsh <> YEAR(beg_pc)


# <?xml version="1.0" encoding="UTF-8"?>
# <kml xmlns="http://earth.google.com/kml/2.2">
#   <Document>
#     <name>ParkLocations.kml</name>
#     <Style id="sh_baseball">
#       <IconStyle>
#         <scale>1.3</scale>
#         <Icon><href>http://www.pair.com/comdog/google_earth/icons/baseball-icon.png</href></Icon>
#       </IconStyle>
#     </Style>
#     <Folder>
#       <name>Major League Baseball stadiums</name>
#       <open>1</open>
#       <LookAt>
#         <longitude>-90.9</longitude>
#         <latitude>34.6</latitude>
#         <altitude>0</altitude>
#         <range>5000000</range>
#         <tilt>0</tilt>
#         <heading>0</heading>
#       </LookAt>
#
#       <Folder>
#         <name>Major League Baseball Stadiums (Demo Games)</name>
#         <open>1</open>
#         <description>Sites for Major League Baseball games that were used only for demonstration games (not regularly used by a team).</description>
#         <LookAt>
#           <longitude>-136.3465002909451</longitude>
#           <latitude>60.66825916169759</latitude>
#           <altitude>0</altitude>
#           <range>8069981.343146238</range>
#           <tilt>0</tilt>
#           <heading>7.939130103370354</heading>
#         </LookAt>
#         --- Placemarks ---
#       </Folder>
#
#       <Folder>
#         <name>Major League Baseball Stadiums of the Past</name>
#         <description>Sites for Major League Baseball games that are no longer in service</description>
#         --- Placemarks ---
#       </Folder>
#
#       <Folder>
#         <name>Major League Baseball Stadiums (2007)</name>
#         <open>1</open>
#         <description>Sites for Major League Baseball games, in current use by teams (2007).</description>
#         --- Placemarks --
#       </Folder>
#
#     </Folder>
#   </Document>
# </kml>

#
#         <Placemark>
#           <name></name>
#           <description>
#             <![CDATA[
#                      <a class="fn org url" href="???">???</a>
#                      <span class="parkID">???</span>
#                      <span class="adr">
#                        <span class="street-address"  >???</span>
#                        <span class="extended-address">???</span>
#                        <span class="locality"        >???</span>
#                        <span class="region"          >???</span>
#                        <span class="postal-code"     >???</span>
#                        <span class="country-name"    >???</span>
#                        <span class="tel"             >???</span>
#                      </span>
#
#             ]]>
#           </description>
#           <LookAt>
#             <longitude>???</longitude>
#             <latitude >???</latitude>
#             <altitude >0</altitude>
#             <range    >1000</range>
#             <tilt     >0</tilt>
#             <heading  >0</heading>
#           </LookAt>
#           <styleUrl>#sh_baseball</styleUrl>
#           <Point>
#             <coordinates>???,???,0</coordinates>
#           </Point>
#         </Placemark>
#
# <a class="fn org url" href="???">???</a>
# <span class="parkID">???</span>
# <span class="adr">
#   <span class="street-address"  >???</span>
#   <span class="extended-address">???</span>
#   <span class="locality"        >???</span>
#   <span class="region"          >???</span>
#   <span class="postal-code"     >???</span>
#   <span class="country-name"    >???</span>
#   <span class="tel"             >???</span>
# </span>
# <span class="geo">
#   <span class="latitude"/>
#   <span class="longitude"/>
#   <span class="altitude"/>
# </span>
# 
