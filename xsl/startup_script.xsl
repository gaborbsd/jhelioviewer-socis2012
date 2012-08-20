<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:math="http://exslt.org/math"
  extension-element-prefixes="math">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="text" encoding="utf-8"/>

  <xsl:template match="/" name="generate.startup.script">
    <xsl:text>#/bin/sh</xsl:text>

    <xsl:apply-templates select="//entry" mode="startup.script"/>
  </xsl:template>

  <xsl:template match="entry" mode="startup.script">

    <!--
	We need to calculate logarithm with base of two to
	solve 4096 / resolution = 2^n to determine the n
	factor that is required by Kakadu but EXSLT only
	provides natural base logarithm so we use the
	log(a,b) = log(x,b) / log(x,a) formula here and
	round the result to fix up inaccuracies.
    -->
    <xsl:variable name="reduceFactor">
      <xsl:value-of select="round(math:log(4096 div resolution) div math:log(2))"/>
    </xsl:variable>

    <xsl:variable name="reduce">
      <xsl:if test="resolution != '4096'">
	<xsl:value-of select="concat(' -R ', $reduceFactor)"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="region">
      <xsl:if test="region">
	<xsl:text> -c "{</xsl:text>
	<xsl:value-of select=".//top"/>,<xsl:value-of select=".//left"/>},{<xsl:value-of select=".//height"/>,<xsl:value-of select=".//width"/>
	<xsl:text>}"</xsl:text>
      </xsl:if>
    </xsl:variable>

if [ ! -p <xsl:value-of select="mount-point"/> ]
then
    rm -f <xsl:value-of select="mount-point"/>
    mkfifo <xsl:value-of select="mount-point"/>
fi

nohup ./<xsl:value-of select="$producer"/> -d <xsl:value-of select="//img-base"/>/<xsl:value-of select="source"/> \
    -f <xsl:value-of select="fps"/> <xsl:value-of select="$reduce"/> <xsl:value-of select="$region"/> \
    -n <xsl:value-of select="sec-per-img"/> &gt;&gt; <xsl:value-of select="mount-point"/> &amp;
nohup ./<xsl:value-of select="$consumer"/> -H localhost -p <xsl:value-of select="//stream-port"/> \
    -l <xsl:value-of select="//stream-pass"/> -m <xsl:value-of select="mount-point"/> \
    -s <xsl:value-of select="mount-point"/> -n "<xsl:value-of select="name"/>" \
    -d "<xsl:value-of select="desc"/>" &amp;
  </xsl:template>
</xsl:stylesheet>
