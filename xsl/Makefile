build-script:
	xsltproc startup_script.xsl ../conf/conf.xml >${SCRIPTDIR}/startup.sh

build-www:
	xsltproc index.xsl ../conf/conf.xml >${WEBDIR}/index.html
	cd ${WEBDIR} && xsltproc ../xsl/channel.xsl ../conf/conf.xml
