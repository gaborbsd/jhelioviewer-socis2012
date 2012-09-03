<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
	Generate a page for each channels.
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

  <xsl:template match="/" name="generate.channel.pages">
    <!-- Iterating over entries -->
    <xsl:for-each select="//entry">
      <xsl:variable name="fname">
	<xsl:value-of select="concat(./@xml:id, '.html')"/>
      </xsl:variable>

      <!-- Create one page per entry -->
      <exsl:document href="{$fname}" method="xml" encoding="utf-8" indent="yes" omit-xml-declaration="yes">
	<xsl:apply-templates select="." mode="channel.page"/>
      </exsl:document>
    </xsl:for-each>
  </xsl:template>

  <!--
	Template to create page for the matched entry.
  -->
  <xsl:template match="entry" mode="channel.page">

    <!-- HTML5 DOCTYPE -->
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

	    <!--
		Refer to the subchannels with HTML5's data- attributes.
	    -->
	    <xsl:attribute name="data-subchannel-{position()}">
	      <xsl:value-of select="concat(//entry[@xml:id = $idRef]/@xml:id, '.html')"/>
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

	<!--
		Add some conditional explanations that depend on whether
		JavaScript is available or not.
	-->
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
		    <a href="{concat($referred/@xml:id, '.html')}">
		      <xsl:value-of select="$referred/name"/>
		    </a>
		  </dt>

		  <dd><xsl:value-of select="$referred/desc"/></dd>
		</xsl:for-each>
	      </dl>
	    </div>
	  </aside>
	</xsl:if>

	<!--
		Link to the JNLP file that launches JHelioviewer.
	-->
	<aside>
	<xsl:call-template name="html.launch.app"/>
	</aside>

	</article>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
