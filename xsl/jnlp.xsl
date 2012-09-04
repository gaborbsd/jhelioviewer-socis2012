<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
	Generate a JNLP file to start the full JHelioviewer app.
-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="xml" encoding="utf-8" indent="yes"/>

  <xsl:template match="/" name="generate.jnlp">
    <jnlp spec="1.0+" codebase="{//urlbase}" href="jhelioviewer.jnlp">
      <information>
	<title>JHelioviewer</title>
	<vendor>European Space Agency</vendor>
	<homepage href="http://jhelioviewer.org/"/>
	<description>JHelioviewer Application</description>
	<offline-allowed/>
      </information>
      <resources>
	<j2se version="1.6+" java-vm-args="-Xmx1000m" href="http://java.sun.com/products/autodl/j2se"/>
	<jar href="JHelioviewer.jar" main="true"/>
      </resources>
      <security>
	<all-permissions/>
      </security>
      <application-desc main-class="org.helioviewer.jhv.JavaHelioViewerLauncher"/>
      <update check="background"/>
    </jnlp>
  </xsl:template>
</xsl:stylesheet>
