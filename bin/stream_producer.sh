#!/bin/sh

#
# Default values for variables
#
KAKADUPATH=./bin
SRCDIR=img
TMPDIR=./tmp
SECPERIMG=3
FPS=4
MODE=loop-dir

usage()
{
	echo "$0 [-d sourcedir] [-K kakadu_path] [-n sec_per_img] [-r resolution] [-c crop] [-f fps] [-R reducefactor] [-t tmpdir] [-m mode] [-p pipe] [-D dateformat]"
	echo "$0 -h"
}

stream_file()
{
	tmpfile=`mktemp --tmpdir=${TMPDIR} -u`

	if [ ! -z "${DATEFORMAT}" ]
	then
		lastmod=`stat -c "%y" ${f}`
		date_formatted=`date --date="${lastmod}" "+%Y-%m-%d %H:%M:%S"`
	fi

	# Extract JPEG 2000 image
	env LD_LIBRARY_PATH=${KAKADUPATH} ${KAKADUPATH}/kdu_expand -i ${f} -o ${tmpfile}.bmp ${REDUCE} ${CROP}

	if [ ! -z "${DATEFORMAT}" ]
	then
		convert -size 110x14 xc:none -gravity center \
			-stroke black -strokewidth 2 \
			-annotate 0 "${date_formatted}" \
			-background none -shadow 110x3+0+0 +repage \
			-stroke none -fill white \
			-annotate 0 "${date_formatted}" \
			${tmpfile}.bmp  +swap -gravity south -geometry +0-3 \
			-composite  ${tmpfile}.new.bmp
		mv ${tmpfile}.new.bmp ${tmpfile}.bmp
	fi

	# Stream to stdout
	ffmpeg -loop_input -i ${tmpfile}.bmp -t ${SECPERIMG} -r ${FPS} ${RESOLUTION} -vcodec libtheora -f ogg -

	# Clean up temporary file
	rm -f ${tmpfile}.bmp
}

while getopts ":c:d:D:f:hK:m:n:p:r:R:t:" opt; do
        case ${opt} in
	h)
		usage
		exit 0
		;;
	c)
		CROP="-region ${OPTARG}"
		;;
        d)
                SRCDIR=${OPTARG}
                ;;
	D)
		DATEFORMAT="${OPTARG}"
		;;
	f)
		FPS=${OPTARG}
		;;
        K)
                KAKADUPATH=${OPTARG}
                ;;
	m)
		MODE=${OPTARG}
		;;
        n)
                SECPERIMG=${OPTARG}
                ;;
	p)
		PIPE=${OPTARG}
		;;
        r)
                RESOLUTION="-s ${OPTARG}"
                ;;
	R)
		REDUCE="-reduce ${OPTARG}"
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

if [ ! -z ${RESOLUTION}  ]
then
	echo "NOTE: using -R to reduce resolution is preferred over -r." >&2
	_RESOLUTION=`echo ${RESOLUTION} | grep -oE '^-s [[:digit:]]+x[[:digit:]]+$'`
	if [ -z ${_RESOLUTION} ]
	then
		echo "Invalid resolution specification. It can only contain digits and an x letter separating the two dimensions." >&2
		exit 2
	fi
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

if [ ! -z ${REDUCE} ]
then
	_REDUCE=`echo ${REDUCE} | grep -oE '^-reduce [[:digit:]]+$'`
	if [ -z ${_REDUCE} ]
	then
		echo "Invalid reduce scale specification. It can only contain digits." >&2
		exit 2
	fi
fi

if [ ! -z ${CROP} ]
then
	_CROP=`echo ${CROP} |  grep -oE '^-region \{[01].[[:digit:]]+,[01].[[:digit:]]+\},\{[01].[[:digit:]]+,[01].[[:digit:]]+\}'`
	if [ -z ${_CROP} ]
	then
		echo "Invalid region specification. It must be in the form {top,left},{height,width}." >&2
		echo "All four values are real numbers between 0 and 1 and top-left corner is {0.0,0.0}." >&2
		exit 2
	fi
fi

if [ ! ${MODE} = "loop-dir" ] && [ ! ${MODE} = "realtime" ] && [ ! ${MODE} = "cyclic-day" ]
then
	echo "Invalid mode. It must be either loop-dir or realtime." >&2
	exit 2
fi

if [ ! -p "${PIPE}" ]
then
	echo "Named pipe does not exist." >&2
	exit 2
fi

# Create temp directory if does not exist
mkdir -p ${TMPDIR}

#
# Main loop to iterate over the images in the source directory
#
if [ ${MODE} = "loop-dir" ]
then
while :
do
	for f in `find ${SRCDIR} -type f -regex '.*\.jp2$' | sort`
	do
		stream_file
	done
done
elif [ ${MODE} = "realtime" ]
then
	while :
	do
		datestr=`date +"%Y/%m/%d"`
		f=`find ${SRCDIR}/${datestr} -type f -regex '.*\.jp2$' | sort | tail -n 1`

		stream_file
	done
elif [ ${MODE} = "cyclic-day" ]
then
	while :
	do
		datestr=`date +"%Y/%m/%d"`
		for f in `find ${SRCDIR}/${datestr} -type f -regex '.*\.jp2$' | sort`
		do
			stream_file
		done
	done
fi
