#!/bin/sh -
# reference: https://trac.ffmpeg.org/wiki/Encode/FFV1
# reference 2: https://www.youtube.com/watch?v=mIWD0oD9_pE

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

if [ "$1" ] && [ "$2" ]; then
    pattern="$1"
    path="$2"
    FRAMERATE=$3
elif [ "$1" ] && [ "$2" != 0] && [ $3 ]; then
    pattern="$1"
    FRAMERATE=$3
    echo "input the path where to save the conformed files (ending in /): "
    echo "input framerate of conformed file: "
elif [ "$1" ] && [ "$2" != 0] && [ $3 != 0]; then
    pattern="$1"
    echo "input the path where to save the conformed files: "
    echo "input framerate of conformed file: "
    read FRAMERATE
else
    echo "input search pattern for files to conform: "
    read pattern
    echo "input the path where to save the conformed files: "
    read path
    echo "input framerate of conformed file: "
    read FRAMERATE
fi

echo -en "conforming search pattern $pattern into ffv1\n"

select yesno in yes no
do case $yesno in
       "no")
	   echo "abort"
	   break
	   ;;
       "yes")
	   find -type f -name "$pattern" \
	       | while read media; \
	       do < /dev/null \
		    ffmpeg -hide_banner -i "$media" -c:v ffv1 -level $FFV1LEVEL -context $FFV1CONTEXT -framerate $FRAMERATE -g $FFV1GOP -threads $FFV1THREADS -slices $FFV1SLICES -slicecrc $FFV1SLICECRC -colorspace $FFV1COLORSPACE -c:a $FFV1AUDIO -ar $FFV1AUDIOHZ "$path""${media%.*}.$FFV1EXTENSION" \
		       && touch -r "$media" "$path""${media%.*}.$FFV1EXTENSION"; \
	       done
	   echo "end of script"
	   break
	   ;;
   esac
done

# input example: frame-%04d.png
# out example: out.mov
# colorspace 0 is YCbCr ("YUV"); 1 is RGB
# GOP 1 for archival
# pix_fmt to select the bits per sample i.e. yuv422p10le
# context 0 (small - default) 1 (large) patterns - no golden rule
# more slices, more multi-threading - few bytes/slice of frame - more crc involved, more robust file
# -coder defaults to 0 if 8bit 1 if more. 2 is custom
