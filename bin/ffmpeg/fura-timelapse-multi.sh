#!/bin/bash -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

## USAGE
if [ ! -f $TIMELAPSE_SCREEN_COORDS ]; then
    echo "file $TIMELAPSE_SCREEN_COORDS missing, list the coords in this file, 1 per line i.e. in 1920x1080+0+0 use 0,0. you can find it by running the xrandr command."
    exit
fi

## START of TEST CODE

# to continue the progressive and not restart at 0, source the subshell
# . fura-timelapse

if [[ `ls` ]]; then
    echo "directory ""$PWD"" not empty, input last frame +1 (without the zeros) to continue"
    read FRAMENUM
fi

if [[ -z $DISPLAY ]]; then
    echo  "input DISPLAY variable i.e. :0.0"
    read DISPLAY
fi

# SECONDS is an internal variable of Bash, avoid unless want to double time at each run.

if [[ $1 ]]; then
    SECS=$1
else
    echo "input seconds between frames."
    read SECS
fi

if [[ $2 ]]; then
    TIMELAPSENAME=$2
elif
    [[ $TIMELAPSENAME ]]; then
    TIMELAPSENAME=$TIMELAPSENAME
else
    echo "input an output name i.e. timelapse_"
    read $TIMELAPSENAME
fi

## END of TEST CODE

## CREATE SCREEN DIRS
counter=0
while read screen; do
    counter=$((counter+1))
    mkdir -p $SCREEN_DIR$counter;
done < $TIMELAPSE_SCREEN_COORDS

# RECORDING CODE
while true;
    do sleep $SECS;
       PROGRESSIVE=$(printf "%0.6i" "$FRAMENUM");
       counter=0
       while read coords; do
	   counter=$((counter+1))
	   ffmpeg -hide_banner -f x11grab -s $TIMELAPSERESOLUTION -i $DISPLAY+$coords -update 1 -frames:v 1 -f image2 -compression_level $TIMELAPSE_PNG_COMPRESSION -q:v $TIMELAPSE_JPG_QUALITY $SCREEN_DIR$counter/"$TIMELAPSENAME$PROGRESSIVE.$TIMELAPSEEXT" &
       done < $TIMELAPSE_SCREEN_COORDS
       wait
       FRAMENUM=$((FRAMENUM+1));
done
