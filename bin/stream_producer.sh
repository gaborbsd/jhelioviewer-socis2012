#!/bin/sh

#
# Default values for variables
#
KAKADUPATH=./bin
SRCDIR=img
TMPDIR=./tmp
SECPERIMG=3
RESOLUTION=1024x1024
FPS=4

usage()
{
	echo "$0 [-d sourcedir] [-K kakadu_path] [-n sec_per_img] [-r resolution] [-t tmpdir]"
	echo "$0 -h"
}

while getopts ":d:f:hK:n:r:t:" opt; do
        case ${opt} in
	h)
		usage
		exit 0
		;;
        d)
                SRCDIR=${OPTARG}
                ;;
	f)
		FPS=${OPTARG}
		;;
        K)
                KAKADUPATH=${OPTARG}
                ;;
        n)
                SECPERIMG=${OPTARG}
                ;;
        r)
                RESOLUTION=${OPTARG}
                ;;
        t)
                TMPDIR=${OPTARG}
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

if [ ! -d ${SRCDIR} ]
then
	echo "Invalid source directory specified." >&2
	exit 2
fi

if [ ! -d ${KAKADUPATH} ] || [ ! -x ${KAKADUPATH}/kdu_expand ]
then
	echo "Invalid Kakadu directory specified." >&2
	exit 2
fi

_RESOLUTION=`echo ${RESOLUTION} | grep -oE '^[[:digit:]]+x[[:digit:]]+$'`

if [ -z ${_RESOLUTION} ]
then
	echo "Invalid resolution specification. It can only contain digits and an x letter separating the two dimensions." >&2
	exit 2
fi

_SECPERIMG=`echo ${SECPERIMG} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_SECPERIMG} ]
then
	echo "Invalid second per image specification. It can only contain digits." >&2
	exit 2
fi

_FPS=`echo ${FPS} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_FPS} ]
then
        echo "Invalid fps specification. It can only contain digits." >&2
        exit 2
fi

# Create temp directory if does not exist
mkdir -p ${TMPDIR}

#
# Main loop to iterate over the images in the source directory
#
while :
do
	for f in `find ${SRCDIR} -type f -regex '.*\.jp2$' | sort`
	do
		# Extract JPEG 2000 image
		env LD_LIBRARY_PATH=${KAKADUPATH} ${KAKADUPATH}/kdu_expand -i ${f} -o ${TMPDIR}/foo.bmp

		# Stream to stdout
		ffmpeg -loop_input -i ${TMPDIR}/foo.bmp -t ${SECPERIMG} -r ${FPS} -s ${RESOLUTION} -vcodec libtheora -f ogg -

		# Clean up temporary file
		rm -f ${TMPDIR}/foo.bmp
	done
done
