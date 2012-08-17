<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes"/>

  <xsl:template match="/" name="generate.channel.pages">
    <xsl:for-each select="//entry">
      <xsl:variable name="fname">
	<xsl:value-of select="concat(./mount-point, '.html')"/>
      </xsl:variable>

      <exsl:document href="{$fname}" method="xml" encoding="utf-8" indent="yes">
	<xsl:apply-templates select="." mode="channel.page"/>
      </exsl:document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="entry" mode="channel.page">
    <html lang="en">
      <head>
	<meta charset="utf-8"/>
	<title><xsl:value-of select="name"/></title>
      </head>

      <body>
	<h1><xsl:value-of select="name"/></h1>

	<video preload="metadata" loop="loop" autoplay="autoplay">
	  <source>
	    <xsl:attribute name="src">
	      <xsl:value-of select="concat('http://', //stream-server, ':', //stream-port, '/', mount-point)"/>
	    </xsl:attribute>

	    <xsl:attribute name="type">
	      <xsl:value-of select="//stream-type"/>
	    </xsl:attribute>
	  </source>

	  <!-- Fallback -->
	  Your browser does not support the HTML5 video tag.
	  Please upgrade or change your browser to
	  <a href="{$videotag.link}">one that
	  supports thee video tag with Ogg Theora format</a> to use this streaming
	  service. Alternatively, you can launch the JHelioviewer application
	  and browse the images on your computer.
	</video>

	<p>The JHelioviewer application has some more advanced features that allow
	  you browsing and manipulating the images on your computer. To launch
	  the application, <a href="{//jnlp-path}">click here</a>.</p>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
