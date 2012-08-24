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
	<title><xsl:value-of select="name"/></title>
	<xsl:call-template name="html.head.common"/>
      </head>

      <body>
	<article>
	<h1><xsl:value-of select="name"/></h1>

	<video preload="metadata" loop="loop" autoplay="autoplay" poster="img/splash{resolution}.png">
	  <source>
	    <xsl:attribute name="src">
	      <xsl:value-of select="concat('http://', //stream-server, ':', //stream-port, '/', mount-point)"/>
	    </xsl:attribute>

	    <xsl:attribute name="type">
	      <xsl:value-of select="//stream-type"/>
	    </xsl:attribute>

	    <xsl:for-each select="subchannels/channel">
	      <xsl:variable name="idRef" select="@href"/>

	      <xsl:attribute name="data-subchannel-{position()}">
		<xsl:value-of select="concat(//entry[@xml:id = $idRef]/mount-point, '.html')"/>
	      </xsl:attribute>
	    </xsl:for-each>
	  </source>

	  <!-- Fallback -->
	  Your browser does not support the HTML5 video tag.
	  Please upgrade or change your browser to
	  <a href="{$videotag.link}">one that
	  supports thee video tag with Ogg Theora format</a> to use this streaming
	  service. Alternatively, you can launch the JHelioviewer application
	  and browse the images on your computer.
	</video>

	<xsl:if test="subchannels">
	  <aside>
	    <p class="hasJs">This channel has subchannels. To jump to a subchannel,
	      clock on an arbitrary point on the video area and you will get another
	      channel with a closer look on the selected area.</p>

	    <p class="noJs">This channel has subchannels but it seems that you
	      have disled JavaScript in your browser.  To use the subchannels
	      feature, enable JavaScript in your browser and reload the page.</p>
	  </aside>
	</xsl:if>

	<aside>
	<xsl:call-template name="html.launch.app"/>
	</aside>

	</article>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
