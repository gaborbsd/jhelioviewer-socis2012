<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- For HTML5 video fallback -->
  <xsl:variable name="videotag.link">http://en.wikipedia.org/wiki/HTML5_video#Browser_support</xsl:variable>

  <!-- Name of the consumer script -->
  <xsl:variable name="consumer">stream_consumer.sh</xsl:variable>

  <!-- Name of the producer script -->
  <xsl:variable name="producer">stream_producer.sh</xsl:variable>

  <!-- Path of color tables relative to HV root dir -->
  <xsl:variable name="palettePath">api/resources/images/color-tables</xsl:variable>

  <!-- Common HTML5 headers -->
  <xsl:template name="html.head.common">
    <meta charset="utf-8" />
    <meta name="description" content="Helioviewer.org - Solar and heliospheric image visualization tool" />
    <meta name="keywords" content="Helioviewer, JPEG 2000, JP2, sun, solar, heliosphere, solar physics, viewer, visualization, space, astronomy, SOHO, SDO, STEREO, AIA, HMI, EUVI, COR, EIT, LASCO, SDO, MDI, coronagraph, " />
        
    <link rel="shortcut icon" href="http://helioviewer.org/favicon.ico" />
    <link rel="stylesheet" href="http://helioviewer.org/build/css/helioviewer.min.css"/>
    <link rel="stylesheet" href="channel.css"/>
  </xsl:template>

  <!-- JHelioviewer ad -->
  <xsl:template name="html.launch.app">
    <p>The JHelioviewer application has some more advanced features that allow
      you browsing and manipulating the images on your computer. To launch
      the application, <a href="jhelioviewer.jnlp">click here</a>.</p>
  </xsl:template>
</xsl:stylesheet>
