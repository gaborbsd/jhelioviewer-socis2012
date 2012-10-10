#!/bin/sh

#
# This script creates a video stream from images.
#
# The script can be configured with various parameters that
# control the characteristics off the created stream and also
# allow some other features, like cropping the image to a specific
# region of interest or adding a timestamp.
#

#
# Default values for variables
#
DURATION=3
FPS=4
WRKDIR=`pwd`
NO_IMAGES=20
FREQ=60

#
# Prints usage info
#
usage()
{
	echo "$0 [-b bitrate] [-c crop] [-d sourcedir] [-D dateformat] [-f fps] [-F renew] [-g maxgop] [-i no_images] [-K kakadu_path] [-n duration] [-p filename] [-P palette] [-r resolution] [-R reducefactor] [-t tmpdir]"
	echo "$0 -h"
}

#
# Sends the image stored in ${f} to the stream.
#
stream_file()
{
	tmpfiles=
	for _f in ${f}
	do
		tmpfile=`mktemp --tmpdir=${TMPDIR} -u`

		# Format the date if DATEFORMAT is set.
		if [ ! -z "${DATEFORMAT}" ]
		then
			lastmod=`echo ${_f} | sed 's|\./\([[:digit:]]*\)_\([[:digit:]]*\)_\([[:digit:]]*\)__\([[:digit:]]*\)_\([[:digit:]]*\)_\([[:digit:]]*\)_.*|\1-\2-\3 \4:\5:\6|'`
			date_formatted=`date --date="${lastmod}" "+%Y-%m-%d %H:%M:%S"`
		fi

		# Extract JPEG 2000 image
		env LD_LIBRARY_PATH=${KAKADUPATH} ${KAKADUPATH}/kdu_expand -i ${_f} -o ${tmpfile}.bmp ${REDUCE} ${CROP}
		convert ${tmpfile}.bmp ${tmpfile}.png
		rm ${tmpfile}.bmp

		# Add palette
		if [ ! -z "${PALETTE}" ]
		then
			php ${WRKDIR}/add_palette.php ${tmpfile}.png ${PALETTE}
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

		tmpfiles="${tmpfiles} ${tmpfile}.png"
	done

	inputs=`echo ${tmpfiles} | sed -e 's| | -i |g' -e 's|^|-i |'`

	# Stream to stdout
	/home/vruiz/ffmpeg/ffmpeg -loop 1 ${inputs} ${BITRATE} ${GOP} -t ${DURATION} -r ${FPS} ${RESOLUTION} -vcodec libtheora -y -f ogg ${dest}

	# Clean up temporary files
	rm -f ${tmpfiles}
}

# Parse command-line arguments
while getopts ":b:c:d:D:f:F:g:i:hK:n:p:P:r:R:t:" opt; do
        case ${opt} in
	h)
		usage
		exit 0
		;;
	b)
		BITRATE="-b ${OPTARG}"
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
		FREQ="${OPTARG}"
		;;
	g)
		GOP="-g ${OPTARG}"
		;;
	i)
		NO_IMAGES="${OPTARG}"
		;;
        K)
                KAKADUPATH=${OPTARG}
                ;;
        n)
                DURATION=${OPTARG}
                ;;
	p)
		SOURCE=${OPTARG}
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
_DURATION=`echo ${DURATION} | grep -oE '^[[:digit:]]+$'`

if [ -z ${_DURATION} ]
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
if [ ! -z "${REDUCE}" ]
then
	_REDUCE=`echo ${REDUCE} | grep -oE '^-reduce [[:digit:]]+$'`
	if [ -z "${_REDUCE}" ]
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

# Check if palette exists
if [ ! -z "${PALETTE}" ] && [ ! -f "${PALETTE}" ]
then
	echo "Palette file does not exist." >&2
	exit 2
fi

# Create temp directory if does not exist
mkdir -p ${TMPDIR}

#
# Main loop to iterate over the images in the source directory
#

dest=${WRKDIR}/${SOURCE}
cnt=0
dest=`echo ${WRKDIR}/${SOURCE} | sed "s|\.ogg|,${cnt}.ogg|"`
pattern=`echo ${SOURCE} | sed 's|\.ogg|(,[[:digit:]]+)?.ogg|'`
while :
do
	datestr=`date +"%Y/%m/%d"`
	srcdir=`echo ${SRCDIR} | sed "s|%%DATE%%|${datestr}|g"`
	cd ${srcdir}
	f=`find . -type f -regex '.*\.jp2$' | tail -n ${NO_IMAGES}`
	if [ "${last}" != "${f}" ]
	then
		stream_file
		cnt=`expr ${cnt} + 1`
		dest=`echo ${WRKDIR}/${SOURCE} | sed "s|\.ogg|,${cnt}.ogg|"`
		find ${WRKDIR} -maxdepth 1 -type f -regex '.*\.ogg'| grep -E "${pattern}" | sort --version-sort -r | tail -n +3 | xargs rm -f
		last=${f}
	fi
	sleep ${FREQ}
done
