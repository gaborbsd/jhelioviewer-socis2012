<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

  <xsl:template match="/" name="generate.index">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
    <html lang="en">
      <head>
        <title>JHelioviewer Channels Index</title>
	<xsl:call-template name="html.head.common"/>
      </head>

      <body>
	<article>
	<p>JHelioviewer provides the following streaming channels
	  with videos of the Sun. The videos are actually created
	  from static images and are encoded in Ogg Theora format.
	  To see these streams, you need a browser that is
	  <a href="{$videotag.link}">compliant with the HTML5 video
	  tag and support Ogg Theora</a>.</p>

	<dl>
	  <xsl:for-each select="//entry">
	    <xsl:variable name="fname">
	      <xsl:value-of select="concat(./@xml:id, '.html')"/>
	    </xsl:variable>

	    <dt><a href="{$fname}"><xsl:value-of select="name"/></a></dt>

	    <dd><xsl:value-of select="desc"/></dd>
	  </xsl:for-each>
	</dl>

	<aside>
	  <xsl:call-template name="html.launch.app"/>
	</aside>

	</article>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
