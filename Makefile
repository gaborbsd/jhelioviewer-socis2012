SUBDIR=		bin
SUBDIR+=	data
SUBDIR+=	xsl

WRKDIR=		$(shell pwd -P)
SCRIPTDIR=	${WRKDIR}/script
WEBDIR=		${WRKDIR}/www

validate:
	@xmllint --noout --valid conf/conf.xml && echo "OK. Configuration file validates."

build-script:
	mkdir -p ${SCRIPTDIR}
	for d in ${SUBDIR}; do \
		make -C $$d build-script SCRIPTDIR=${SCRIPTDIR}; \
	done

build-www:
	mkdir -p ${WEBDIR}
	for d in ${SUBDIR}; do \
		make -C $$d build-www WEBDIR=${WEBDIR}; \
	done
	mkdir -p ${WEBDIR}/img
	cp -R img/*.png ${WEBDIR}/img/

clean:
	rm -rf ${SCRIPTDIR} ${WEBDIR}
