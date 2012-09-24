#!/bin/sh

#
# This script reads the specified source and sends the read data
# to an Icecast streaming server. The script needs the authentication
# settings to be properly configured through the command line
# parameters. Optionally, the channem name and description can also
# be specified.
#

#
# Default variable values
#
SOURCE=stream.ogg
STREAMHOST=localhost
STREAMPORT=4551
MOUNTPOINT=helio.ogg
NAME="Unnamed Video Stream"
DESC="JHelioviewer Video Channel"

usage()
{
	echo "$0 [-d desc] [-H host] [-l pass] [-m mount_point] [-n name] [-p port] [-s source]"
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
		SOURCE=${OPTARG}
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

# The stream port contains one or more digits
_STREAMPORT=`echo ${STREAMPORT} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_STREAMPORT} ]
then
	echo "Invalid stream port specification. It can only contain digits." >&2
	exit 2
fi

#
# Main loop to read out video data from the source and send it to
# the streaming server
#

while :
do
	pattern=`echo ${SOUCE} | sed 's|\.ogg|(,[[:digit:]]+)?.ogg|'`
	input=`find . -type f | grep -E "${pattern}" | sort | tail -n 1`
	oggfwd -n "${NAME}" -d "${DESC}" ${STREAMHOST} ${STREAMPORT} ${STREAMPASS} /${MOUNTPOINT} < ${input}
done
