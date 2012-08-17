<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="text" encoding="utf-8"/>

  <xsl:template match="/" name="generate.startup.script">
    <xsl:text>#/bin/sh</xsl:text>

    <xsl:apply-templates select="//entry" mode="startup.script"/>
  </xsl:template>

  <xsl:template match="entry" mode="startup.script">

if [ ! -p <xsl:value-of select="mount-point"/> ]
then
    rm -f <xsl:value-of select="mount-point"/>
    mkfifo <xsl:value-of select="mount-point"/>
fi

nohup <xsl:value-of select="$producer"/> -d <xsl:value-of select="source"/> -r <xsl:value-of select="resolution"/> -n <xsl:value-of select="sec-per-img"/> > <xsl:value-of select="mount-point"/> &amp;
nohup <xsl:value-of select="$consumer"/> -H <xsl:value-of select="//stream-server"/> -p <xsl:value-of select="//stream-port"/> -l <xsl:value-of select="//stream-pass"/> -m <xsl:value-of select="mount-point"/> -s <xsl:value-of select="mount-point"/> &amp;
  </xsl:template>
</xsl:stylesheet>
