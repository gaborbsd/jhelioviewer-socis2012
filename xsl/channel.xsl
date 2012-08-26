<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

  <xsl:template match="/" name="generate.channel.pages">
    <xsl:for-each select="//entry">
      <xsl:variable name="fname">
	<xsl:value-of select="concat(./mount-point, '.html')"/>
      </xsl:variable>

      <exsl:document href="{$fname}" method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes">
	<xsl:apply-templates select="." mode="channel.page"/>
      </exsl:document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="entry" mode="channel.page">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
    <html lang="en">
      <head>
	<title><xsl:value-of select="name"/></title>
	<xsl:call-template name="html.head.common"/>
	<script type="text/javascript" src="channel.js">/* empty */</script>
      </head>

      <body>
	<article>
	<h1><xsl:value-of select="name"/></h1>

	<video id="videoarea" preload="metadata" loop="loop" autoplay="autoplay" poster="img/splash{resolution}.png">
	  <xsl:for-each select="subchannels/channel">
	    <xsl:variable name="idRef" select="@href"/>

	    <xsl:attribute name="data-subchannel-{position()}">
	      <xsl:value-of select="concat(//entry[@xml:id = $idRef]/mount-point, '.html')"/>
	    </xsl:attribute>

	    <xsl:attribute name="onclick">redirectToSubChannel(event);</xsl:attribute>

	    <xsl:attribute name="onmouseover">changeMousePointer(event);</xsl:attribute>
	  </xsl:for-each>

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

	<xsl:if test="subchannels">
	  <aside>
	    <p class="hasJs">This channel has subchannels. To jump to a subchannel,
	      click on an arbitrary point on the video area and you will be redirected to another
	      channel with a closer look on the selected area.</p>

	    <div class="noJs">
	      <p>This channel provides the following subchannels:</p>

	      <dl>
		<xsl:for-each select="subchannels/channel">
		  <xsl:variable name="idRef" select="@href"/>
		  <xsl:variable name="referred" select="//entry[@xml:id = $idRef]"/>

		  <dt>
		    <a href="{concat($referred/mount-point, '.html')}">
		      <xsl:value-of select="$referred/name"/>
		    </a>
		  </dt>

		  <dd><xsl:value-of select="$referred/desc"/></dd>
		</xsl:for-each>
	      </dl>
	    </div>
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
