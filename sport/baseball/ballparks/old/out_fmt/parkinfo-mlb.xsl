<?xml version='1.0' encoding='utf-8' ?>
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp "&#160;">]>

<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"                
                xmlns:html="http://www.w3.org/1999/xhtml">
<xsl:output method="xml" indent="yes"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            />

<!-- Main document template -->
<xsl:template match="/teams">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/xhtml; charset=UTF-8" />
  <title>Team Info</title>
  <link rel="stylesheet" type="text/css" media="screen" href="parkinfo-mlb.css" />
</head>
<body>

<table style="width:100%">
  <tr>
  <td class="intro">
    <!-- Calls html:* template below to embed the html description -->
    <xsl:apply-templates select="intro/*"/>
  </td>
  </tr>

  <xsl:for-each select="/teams/team">
  <tr valign="top">
  <td class="team">

    <div class="vcard">
      <h1 class="fn org url"><a href="http://{@url}" class="fn org url"><xsl:value-of select="@name"/></a></h1>
      <div class="adr">
        <span class="extended-address"><xsl:value-of select="@parkname"/>
        <xsl:if test='boolean(string(@extaddr))'><br/><xsl:value-of select="@extaddr"/></xsl:if><br/></span>
        <span class="street-address"  ><xsl:value-of select="@streetaddr"/></span><br />
        <span class="locality"        ><xsl:value-of select="@city"/></span>,&nbsp;<span class="region"><xsl:value-of select="@state"/></span>&nbsp;<span class="country-name"><xsl:value-of select="@country"/></span>&nbsp;<span class="postal-code"><xsl:value-of select="@zip"/></span>
      </div>
      <span class="tel"             ><xsl:value-of select="@tel"/></span><br />
      <a class="url english" href="http://{@url}"><xsl:value-of select="@url"/></a><br />
      <xsl:if test='boolean(string(@spanishurl))'><a class="url spanish" href="http://{@spanishurl}"><xsl:value-of select="@spanishurl"/></a><br /></xsl:if>
    </div>
    <div  class="logo"><a href="http://{@url}"><img class="logo" src="http://mlb.com/mlb/images/team_logos/{@logofile}" width="79" height="76" alt="{@name} Logo" /></a></div>
    
  </td>
  </tr>
  </xsl:for-each>

</table>
</body>
</html>
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

