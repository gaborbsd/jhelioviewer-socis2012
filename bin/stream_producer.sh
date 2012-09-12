#!/bin/sh

#
# This script creates a video stream from images and outputs the
# stream to stdout. The script has three different modes:
#
# (1) loop-dir: Loops the specified directory and repeats the
#     contained images all the time.
#
# (2) realtime: In this case, only the sensor directory should
#     be specified and the script finds the images for the
#     current date and always emits the last image.
#
# (3) cyclic-day: In this case, only the sensor directory should
#     be specified and the script finds the images for the
#     current day and iterates through the images of the current
#     day, including the recently arrived new images in each
#     iteration.
#
# The script can be configured with various parameters that
# control the characteristics off the created stream and also
# allow some other features, like cropping the image to a specific
# region of interest or adding a timestamp.
#

#
# Default values for variables
#
KAKADUPATH=./bin
SRCDIR=img
TMPDIR=./tmp
SECPERIMG=3
FPS=4
MODE=loop-dir

#
# Prints usage info
#
usage()
{
	echo "$0 [-d sourcedir] [-K kakadu_path] [-n sec_per_img] [-r resolution] [-c crop] [-f fps] [-R reducefactor] [-t tmpdir] [-m mode] [-p pipe] [-P palette] [-D dateformat] [-F]"
	echo "$0 -h"
}

#
# Sends the image stored in ${f} to the stream.
#
stream_file()
{
	tmpfile=`mktemp --tmpdir=${TMPDIR} -u`

	# Format the date if DATEFORMAT is set.
	if [ ! -z "${DATEFORMAT}" ]
	then
		lastmod=`stat -c "%y" ${f}`
		date_formatted=`date --date="${lastmod}" "+%Y-%m-%d %H:%M:%S"`
	fi

	# Extract JPEG 2000 image
	env LD_LIBRARY_PATH=${KAKADUPATH} ${KAKADUPATH}/kdu_expand -i ${f} -o ${tmpfile}.bmp ${REDUCE} ${CROP}
	convert ${tmpfile}.bmp ${tmpfile}.png
	rm ${tmpfile}.bmp

	# Add palette
	if [ ! -z "${PALETTE}" ]
	then
		php add_palette.php ${tmpfile}.png ${PALETTE}
	fi

	# Only add date if DATEFORMAT is set
	if [ ! -z "${DATEFORMAT}" ]
	then
		convert -size 110x14 xc:none -gravity center \
			-stroke black -strokewidth 2 \
			-annotate 0 "${date_formatted}" \
			-background none -shadow 110x3+0+0 +repage \
			-stroke none -fill white \
			-annotate 0 "${date_formatted}" \
			${tmpfile}.png  +swap -gravity south -geometry +0-3 \
			-composite  ${tmpfile}.new.png
		mv ${tmpfile}.new.png ${tmpfile}.png
	fi

	# Stream to stdout
	ffmpeg -loop_input -i ${tmpfile}.png -t ${SECPERIMG} -r ${FPS} ${RESOLUTION} -vcodec libtheora -f ogg -

	# Clean up temporary file
	rm -f ${tmpfile}.png
}

# Parse command-line arguments
while getopts ":c:d:D:f:FhK:m:n:p:P:r:R:t:" opt; do
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
	F)
		FILE=yes
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
	P)
		PALETTE=${OPTARG}
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

# The source directory must exist.
if [ ! -d ${SRCDIR} ]
then
	echo "Invalid source directory specified." >&2
	exit 2
fi

# The path to Kakadu must exist and must contain kdu_expand
if [ ! -d ${KAKADUPATH} ] || [ ! -x ${KAKADUPATH}/kdu_expand ]
then
	echo "Invalid Kakadu directory specified." >&2
	exit 2
fi

# Emit warning if resolution is set with ffmpeg instead of kdu_expand
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

# Seconds value contains one or more digit
_SECPERIMG=`echo ${SECPERIMG} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_SECPERIMG} ]
then
	echo "Invalid second per image specification. It can only contain digits." >&2
	exit 2
fi

# FPS value contains one or more digit
_FPS=`echo ${FPS} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_FPS} ]
then
        echo "Invalid fps specification. It can only contain digits." >&2
        exit 2
fi

# Reduce value contains one or more digit
if [ ! -z ${REDUCE} ]
then
	_REDUCE=`echo ${REDUCE} | grep -oE '^-reduce [[:digit:]]+$'`
	if [ -z ${_REDUCE} ]
	then
		echo "Invalid reduce scale specification. It can only contain digits." >&2
		exit 2
	fi
fi

# Crop value contains two pairs of real numbers, both pairs enclosed into
# {} brackets and separated by comma.
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

# Mode can only take these specific values
if [ ! ${MODE} = "loop-dir" ] && [ ! ${MODE} = "realtime" ] && [ ! ${MODE} = "cyclic-day" ]
then
	echo "Invalid mode. It must be either loop-dir or realtime." >&2
	exit 2
fi

# Check if palette exists
if [ ! -z "${PALETTE}" ] && [ ! -f "${PALETTE}" ]
then
	echo "Palette file does not exist." >&2
	exit 2
fi

# Named pipe must exist
if [ -z "${FILE}" ] &&&&  


[ ! -p "${PIPE}" ]
then
	echo "Named pipe does not exist." >&2
	exit 2
fi

# Create temp directory if does not exist
mkdir -p ${TMPDIR}

#
# Main loop to iterate over the images in the source directory
#

# loop-dir only iterates on the directory inside an infinite loop
if [ ${MODE} = "loop-dir" ]
then
while :
do
	for f in `find ${SRCDIR} -type f -regex '.*\.jp2$' | sort`
	do
		stream_file
	done
done

# realtime always takes the last image in current day's directory
elif [ ${MODE} = "realtime" ]
then
	while :
	do
		datestr=`date +"%Y/%m/%d"`
		srcdir=`echo ${SRCDIR} | sed "s|%%DATE%%|${datestr}|g"`
		f=`find ${srcdir} -type f -regex '.*\.jp2$' | sort | tail -n 1`

		stream_file
	done

# cyclic-day always iterates on the current day's directory and subsequent calls
# of find will always take more and more images.
elif [ ${MODE} = "cyclic-day" ]
then
	while :
	do
		datestr=`date +"%Y/%m/%d"`
		srcdir=`echo ${SRCDIR} | sed "s|%%DATE%%|${datestr}|g"`
		for f in `find ${srcdir} -type f -regex '.*\.jp2$' | sort`
		do
			stream_file
		done
	done
fi
