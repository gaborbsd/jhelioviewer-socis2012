#!/bin/sh

PIPE=stream.ogg
STREAMHOST=localhost
STREAMPORT=4551
STREAMPASS=changeme
MOUNTPOINT=helio.ogg
NAME="Unnamed Video Stream"
DESC="JHelioviewer Video Channel"

usage()
{
	echo "$0 [-H host] [-p port] [-l pass] [-m mount_point] [-s pipe] [-n name] [-d desc]"
	echo "$0 -h"
}

while getopts ":d:hH:l:m:n:p:s:" opt; do
	case ${opt} in
	d)
		DESC="${OPTARG}"
		;;
	h)
		usage
		exit 0
		;;
	H)
		STREAMHOST=${OPTARG}
		;;
	l)
		STREAMPASS=${OPTARG}
		;;
	m)
		MOUNTPOINT=${OPTARG}
		;;
	n)
		NAME="${OPTARG}"
		;;
	p)
		STREAMPORT=${OPTARG}
		;;
	s)
		PIPE=${OPTARG}
		;;
	\?)
		echo "Invalid option: -${OPTARG}" >&2
		usage
		exit 1
		;;
	:)
		echo "Option -${OPTARG} requires an argument." >&2
		usage
		exit 1
		;;
	esac
done

#
# Some sanity check on the parameters follow
#

if [ ! -p ${PIPE} ]
then
	echo "Specified named pipe ${PIPE} does not exist." >&2
	exit 2
fi

_STREAMPORT=`echo ${STREAMPORT} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_STREAMPORT} ]
then
	echo "Invalid stream port specification. It can only contain digits." >&2
	exit 2
fi

#
# Main loop to read out video data from the named pipe and send it to
# the streaming server
#

while :
do
	oggfwd -n "${NAME}" -d "${DESC}" ${STREAMHOST} ${STREAMPORT} ${STREAMPASS} /${MOUNTPOINT} < ${PIPE}
done
