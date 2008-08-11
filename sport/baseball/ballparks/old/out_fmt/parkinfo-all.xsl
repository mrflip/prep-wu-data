<?xml version='1.0' encoding='utf-8' ?>
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp "&#160;">]>

<xsl:stylesheet version="1.0" 
                xmlns:xsl ="http://www.w3.org/1999/XSL/Transform"                
                xmlns:html="http://www.w3.org/1999/xhtml"	            
                >
<!-- <xsl:import href="exslt/date/date.xsl" />

                xmlns:math="http://exslt.org/math"
                xmlns:str ="http://exslt.org/str"
                xmlns:date="http://exslt.org/date"
                extension-element-prefixes="math date str"
 
                xmlns:fn="http://www.w3.org/2005/02/xpath-functions"

      <xsl:call-template name="date:format-date">
        <xsl:with-param name="date-time" select="xs:date('2000-01-01')" />
        <xsl:with-param name="pattern" select="string" />
      </xsl:call-template>
-->

<xsl:output method="xml" indent="yes"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            />



<!-- Main document template -->
<xsl:template match="/parks">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/xhtml; charset=UTF-8" />
  <title>Baseball Stadium Info: Current, Past and Future Ballparks</title>
  <link rel="stylesheet" type="text/css" media="screen" href="parkinfo-all.css" />
</head>
<body>

<table style="width:100%">
  <!-- Table header: list columns -->
  <thead>
    <tr>
      <td align="center" class="head" colspan="1">Name</td>
      <td align="center" class="head">ID</td>
      <td align="center" class="head">Begin</td>
      <td align="center" class="head">End</td>
      <td align="center" class="head">Total Games</td>
      <td align="center" class="head">Latitude</td>
      <td align="center" class="head">Longitude</td>
    </tr>
  </thead>

  <xsl:for-each select="/parks/park">
    <xsl:if test='1 or boolean(string(@tel))'>

    <tr class="park" valign="top">
      <td colspan="1" >
        <h1 class="fn org url">
          <xsl:if test='boolean(string(@extaddr))'><a href="http://{@url}" class="fn org url"><xsl:value-of select="@name"/></a></xsl:if>
          <xsl:if test='not(string(@extaddr))'    ><xsl:value-of select="@name"/></xsl:if>
        </h1>
      </td>
      <td class="uid"><xsl:value-of select="@parkID"/></td>
      <td><xsl:apply-templates select="@beg"/></td>
      <td><xsl:apply-templates select="@end"/></td>
      <td><xsl:value-of select="@games"/></td>
      <td><xsl:if test='boolean(string(@lat))'><xsl:value-of select="format-number(@lat, '###.0000')"/></xsl:if></td>
      <td><xsl:if test='boolean(string(@lng))'><xsl:value-of select="format-number(@lng, '###.0000')"/></xsl:if></td>
    </tr>

    <tr>
      <td class="address">
        <div class="logo"><a href="http://{@url}"><img class="logo" src="http://mlb.com/mlb/images/team_logos/{@logofile}" width="79" height="76" alt="{@name} Logo" /></a></div>
        <div class="vcard">
          <div class="adr">
            <xsl:if test='boolean(string(@extaddr))'   ><span class="extended-address"><xsl:value-of select="@extaddr"   /></span><br/></xsl:if>
            <xsl:if test='boolean(string(@streetaddr))'><span class="street-address"  ><xsl:value-of select="@streetaddr"/></span><br /></xsl:if>
            <span class="locality"        ><xsl:value-of select="@city"/></span>,&nbsp;<span class="region"><xsl:value-of select="@state"/></span>&nbsp;<span class="country-name"><xsl:value-of select="@country"/></span>&nbsp;<span class="postal-code"><xsl:value-of select="@zip"/></span>
          </div>
          <xsl:if test='boolean(string(@tel))'       ><span class="tel"><xsl:value-of select="@tel"/></span><br /></xsl:if>
          <xsl:if test='boolean(string(@tel))'       ><a class="url english" href="http://{@url}"       ><xsl:value-of select="@url"       /></a><br /></xsl:if>
          <xsl:if test='boolean(string(@spanishurl))'><a class="url spanish" href="http://{@spanishurl}"><xsl:value-of select="@spanishurl"/></a><br /></xsl:if>
        </div>
      </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>

    <xsl:for-each select="team">
      <tr>
      <td>==Team Name==</td>
      <td><xsl:value-of select="@teamID"/></td>
      <td><xsl:apply-templates select="@beg"/></td>
      <td><xsl:apply-templates select="@end"/></td>
      <td><xsl:value-of select="@games"/></td>
      </tr>
    </xsl:for-each> 
    
    <tr>
      <td class="parkcomment" colspan="6">
        <ul>
        <xsl:for-each select="comment">
          <li><xsl:value-of select="@comment"/></li>
        </xsl:for-each> 
        </ul>
      </td>
    </tr>

    </xsl:if>
  </xsl:for-each>

</table>


<!--
<p class="intro">
  <p class="description">This XML file gives information on every major league baseball park
  in <a href="http://retrosheet.org/">retrosheet.org</a>'s gamelogs collection.  Included (where available) are<ul>
  <li>Name and name history, retrosheet ID and names found in other popular sources;</li>
  <li>Address, telephone, logo and website information for currently-operating stadiums;</li>
  <li>Latitude and longitude information</li>
  <li>Dates of first and last games and number of games played;</li>
  <li>and each team that played in that park, whether home or as a neutral site, along with dates and number of games played</li>
  </ul></p>

  <p class="credits">The information was obtained from <ul>
  <li><a href="">Retrosheet.org</a>: <a href="http://retrosheet.org/gamelogs/index.html">gamelog</a> 
  and <a href="http://retrosheet.org/game.htm">event files</a>.</li>
  <li><a href="http://bioproj.sabr.org/bioproj.cfm?a=w&amp;w=v&amp;biogID=18">David Vincent</a>:
  List of 'Alternate Site Games' (games played away from a team's home park) 
  (<a href="http://www.retrosheet.org/neutral19.htm">pre 1900</a>/ 
  <a href="http://www.retrosheet.org/neutral.htm">post 1900</a>).</li>
  <li><a href="http://bbs.keyhole.com/ubb/showflat.php/Cat/0/Number/783779/Main/721289">Google Earth user 'alstrand'</a>: 
  KML files geolocating 
  <a href="http://bbs.keyhole.com/ubb/download.php?Number=721289">National League</a> and 
  <a href="http://bbs.keyhole.com/ubb/download.php?Number=721294">American League</a> parks of the past and present.</li>
  <li>MLB's <a href="http://mlb.mlb.com/team/index.jsp">Team Index</a> listing name, url and address information for each team.</li>
  <li>I also drew on Retrosheet's <a href="http://www.retrosheet.org/parkcode.txt">parkcodes.txt</a> 
  and the more modern <a href="http://retrosheet.org/boxesetc/MISC/PKDIR.htm">park directory</a> files.</li>
</ul>
  </p>

  <p class="aboutxslt">If you are looking at this file with a
  decent browser, you will see a formatted table.  Don't be
  fooled! It's really XML, pretty printed with an <a
  href="http://www.w3schools.com/xsl">XSLT stylesheet</a>.
  Either "View Source" or <a href="#">right click here</a>
  and choose "Save As..." from your browser's menu and you will have
  the nicely structured dataset, suitable for import into most
  <a href="http://effbot.org/zone/element-index.htm" title="Element Tree - structured XML for python">modern</a><xsl:text> </xsl:text>
  <a href="http://search.cpan.org/~grantm/XML-Simple-2.18/lib/XML/Simple.pm" title="XML::Simple - structured XML for perl">data-munging</a> <xsl:text> </xsl:text>
  <a href="http://livedocs.adobe.com/flex/2/langref/XML." title="Flex/Actionscript have XML as an atomic type. Wow!">tools</a>.</p>
</p>
-->



</body>
</html>
</xsl:template>


<!-- Dates in "Mon, DD, YYYY" format -->
<xsl:template match="@beg|@end">
  <xsl:if test="not(string(.) = 'NULL')">
  <xsl:value-of select="substring('JanFebMarAprMayJunJulAugSepOctNovDec',3*substring(., 6,2) - 2,3)" />
  <xsl:text> </xsl:text><xsl:value-of select="substring(.,9,2)" />, <xsl:value-of select="substring(.,1,4)" />
  </xsl:if>
</xsl:template>




<!-- This makes HTML content come out correctly embedded and
     namespaced.  Note that all html tags in the source XML doc have
     to have "html:" prepended, like <html:p>foo</html:p>
-->
<xsl:template match="html:*">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
    <xsl:for-each select="@*">
      <xsl:attribute name="{local-name()}">
        <xsl:value-of select="." />
      </xsl:attribute>
    </xsl:for-each>
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>


</xsl:stylesheet>
