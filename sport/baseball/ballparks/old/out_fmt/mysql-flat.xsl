<?xml version='1.0' encoding='utf-8' ?>
<!DOCTYPE xsl:stylesheet [<!ENTITY nbsp "&#160;">]>

<xsl:stylesheet version="1.0"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>
<xsl:template match="/">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <title>MySQL Result Set</title>
  <link rel="stylesheet" type="text/css" media="screen" href="mysql-flat.css" />
</head>
<body>

<table style="width:100%;">
  <thead>
    <tr>
      <xsl:for-each select="/rows/row[1]/@*"><td align="center" class="head">
        <xsl:value-of select="local-name(.)"/>
      </td></xsl:for-each>
    </tr>
  </thead>
  <xsl:for-each select="/rows/row">
  <tr valign="top">
    <xsl:for-each select="@*">
    <td class="">
      <xsl:value-of select="."/>
    </td>
    </xsl:for-each>
  </tr>
  </xsl:for-each>
  
</table>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
