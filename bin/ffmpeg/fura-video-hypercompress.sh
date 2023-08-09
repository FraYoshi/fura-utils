#!/bin/sh -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

INPUT=$1

# 0.004 for 25fps
# 0.002 for 50 fps or 25fps long records
# 0.001 for 50 fps long records
#scale=256x144

#scale=426x240 # the best compromise at crf 40

if [ $2 ]; then
    factor=$2
else
    echo -en "which dot factor to use? [higher = longer]\nsuggested values:\n"
    echo -en "[032] short videos [004] for 25fps [002] for 50 fps or 25fps long records [001] for 50 fps long records\n"

    select dotFactor in manual 001 002 004 008 016 032
    do case $dotFactor in
	   "manual")
	       echo "input dot factor (higher = longer) i.e 128"
	       read factor
	       break
	       ;;
	   "001")
	       factor=001
	       break
	       ;;
	   "002")
	       factor=002
	       break
	       ;;
	   "004")
	       factor=004
	       break
	       ;;
	   "008")
	       factor=008
	       break
	       ;;
	   "016")
	       factor=016
	       break
	       ;;
	   "032")
	       factor=032
	       break
	       ;;
       esac
    done
fi

ffmpeg -an -i "$INPUT" -s $HYPERSCALE -c:v libx265 -crf $HYPERCRF -preset $HYPERPRESET -filter:v "setpts=0.$factor*PTS" "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT \
    && touch -r "${INPUT}" "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT \
    && exiftool -overwrite_original -All= "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT
