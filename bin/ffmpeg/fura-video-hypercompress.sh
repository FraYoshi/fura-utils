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

if [ $3 ]; then
    fps=$3
else
    echo -en "which frame rate to use?\n"
    echo -en "higher framerates will result in bigger files - capping seems like to be 12800 fsp\n"
    echo -en "WARNING! if a format other than mkv is configured, not all fps are usable, only the standard ones\n"
    
    select fpsHyper in manual 15 25 30 50 60 100 120 150 450 1920 12800
    do case $fpsHyper in
	   "manual")
	       echo "input fps value (higher = condensed details) i.e. 1000"
	       read fps
	       break
	       ;;
	   "15")
	       fps=15
	       break
	       ;;
	   "25")
	       fps=25
	       break
	       ;;
	   "30")
	       fps=30
	       break
	       ;;
	   "50")
	       fps=50
	       break
	       ;;
	   "60")
	       fps=60
	       break
	       ;;
	   "100")
	       fps=100
	       break
	       ;;
	   "120")
	       fps=120
	       break
	       ;;
	   "150")
	       fps=150
	       break
	       ;;
	   "450")
	       fps=450
	       break
	       ;;
	   "1920")
	       fps=1920
	       break
	       ;;
	   "12800")
	       fps=12800
	       break
	       ;;
       esac
    done
fi
		     

ffmpeg -an -i "$INPUT" -s $HYPERSCALE -r $fpsHyper -c:v libx265 -crf $HYPERCRF -preset $HYPERPRESET -filter:v "setpts=0.$factor*PTS" "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT \
    && touch -r "${INPUT}" "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT \
    && exiftool -overwrite_original -All= "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT \
    && touch -r "${INPUT}" "$HYPEROUTDIR""${INPUT%.*}""$HYPEREXT".$HYPERFORMAT
