<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:math="http://exslt.org/math"
  extension-element-prefixes="math">

  <xsl:import href="includes.xsl"/>

  <xsl:output method="text" encoding="utf-8"/>

  <xsl:template name="entries">
    <xsl:param name="nodeSet"/>
    <xsl:param name="processed" select="''"/>

    <xsl:choose>
      <xsl:when test="count($nodeSet) = 0">
	<xsl:value-of select="$processed"/>
      </xsl:when>

      <xsl:otherwise>
	<xsl:call-template name="entries">
	  <xsl:with-param name="nodeSet" select="$nodeSet[position() != 1]"/>
	  <xsl:with-param name="processed" select="concat($processed, ' ', $nodeSet[1]/@xml:id)"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/" name="generate.startup.script">
    <xsl:variable name="entries">
      <xsl:call-template name="entries">
	<xsl:with-param name="nodeSet" select="//entry"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:text>#/bin/sh
</xsl:text>

    <xsl:apply-templates select="//entry" mode="startup.script"/>

if [ $# -eq 1 ]
then
  for ch in <xsl:value-of select="$entries"/>
  do
    $ch $1 all
  done
elif [ $# -eq 2 ]
then
  $1 $2 all
fi
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

    <xsl:variable name="dateFormat">
      <xsl:if test="dateformat">
        <xsl:text> -D "</xsl:text>
        <xsl:value-of select="./dateformat"/>
        <xsl:text>"</xsl:text>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="palette">
      <xsl:if test="palette">
        <xsl:text> -P "</xsl:text>
        <xsl:value-of select="./palette"/>
        <xsl:text>"</xsl:text>
      </xsl:if>
    </xsl:variable>

<xsl:value-of select="@xml:id"/> () {
if [ "$1" == "check" ]
then
  if [ "$2" == "producer" ]
  then
    ps aux | grep -F producer | grep -qF <xsl:value-of select="@xml:id"/> || <xsl:value-of select="@xml:id"/> start producer
  elif [ "$2" == "consumer" ]
  then
    ps aux | grep -F consumer | grep -qF <xsl:value-of select="@xml:id"/> || <xsl:value-of select="@xml:id"/> start consumer
  elif [ "$2" == "all" ]
  then
    <xsl:value-of select="@xml:id"/> check producer
    <xsl:value-of select="@xml:id"/> check consumer
  else
    echo "Wrong check argument." &gt;&amp;2
  fi
elif [ "$1" == "start" ]
then
  if [ ! -p <xsl:value-of select="mount-point"/> ]
  then
    rm -f <xsl:value-of select="mount-point"/>
    mkfifo <xsl:value-of select="mount-point"/>
  fi

  if [ "$2" == "producer" ]
  then
    ./<xsl:value-of select="$producer"/> -d <xsl:value-of select="//img-base"/>/<xsl:value-of select="source"/> \
      -f <xsl:value-of select="fps"/> <xsl:value-of select="$reduce"/> <xsl:value-of select="$region"/> \
      -n <xsl:value-of select="sec-per-img"/> -m <xsl:value-of select="@mode"/> \
      -p <xsl:value-of select="mount-point"/> <xsl:value-of select="$dateFormat"/> \
      <xsl:value-of select="$palette"/> \
      &gt;&gt; <xsl:value-of select="mount-point"/> 2&gt;/dev/null &amp;
  elif [ "$2" == "consumer" ]
  then
    ./<xsl:value-of select="$consumer"/> -H localhost -p <xsl:value-of select="//stream-port"/> \
      -l <xsl:value-of select="//stream-pass"/> -m <xsl:value-of select="mount-point"/> \
      -s <xsl:value-of select="mount-point"/> -n "<xsl:value-of select="name"/>" \
      -d "<xsl:value-of select="desc"/>" &amp;
  elif [ "$2" == "all" ]
  then
    <xsl:value-of select="@xml:id"/> start producer
    <xsl:value-of select="@xml:id"/> start consumer
  else
    echo "Wrong start argument." &gt;&amp;2
  fi
elif [ "$1" == "stop" ]
then
  if [ "$2" == "producer" ]
  then
    pid=`ps aux | grep -F producer | grep -F <xsl:value-of select="@xml:id"/> | awk '{print $2}'`
    if [ "${pid}" != "" ]
    then
      kill -KILL ${pid}
    fi
  elif [ "$2" == "consumer" ]
  then
    pid=`ps aux | grep -F consumer | grep -F <xsl:value-of select="@xml:id"/> | awk '{print $2}'`
    if [ "${pid}" != "" ]
    then
      kill -KILL ${pid}
    fi
  elif [ "$2" == "all" ]
  then
    <xsl:value-of select="@xml:id"/> stop producer
    <xsl:value-of select="@xml:id"/> stop consumer
    rm -rf <xsl:value-of select="@xml:id"/>*
  fi
fi
}

</xsl:template>
</xsl:stylesheet>
