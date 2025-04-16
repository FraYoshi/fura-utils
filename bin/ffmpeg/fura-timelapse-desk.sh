#!/bin/bash -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

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
    CAPTURECOORD=$2
elif
    [[ $CAPTURECOORD ]]; then
    CAPTURECOORD=$CAPTURECOORD
else
    echo -e "input desktop coordinates from xrandr. default is 0,0"
    read CAPTURECOORD
fi

if [[ $3 ]]; then
    TIMELAPSENAME=$3
elif
    [[ $TIMELAPSENAME ]]; then
    TIMELAPSENAME=$TIMELAPSENAME
else
    echo "input an output name i.e. timelapse_"
    read $TIMELAPSENAME
fi

if [[ $4 ]]; then
    TIMELAPSERESOLUTION=$4
elif
    [[ $TIMELAPSERESOLUTION ]]; then
    TIMELAPSERESOLUTION=$TIMELAPSERESOLUTION
else
    echo "input a resolution i.e. 1920x1080"
    read $TIMELAPSERESOLUTION
fi

## END of TEST CODE

while true;
    do sleep $SECS;
       PROGRESSIVE=$(printf "%0.6i" "$FRAMENUM");
       ffmpeg -hide_banner -f x11grab -s $TIMELAPSERESOLUTION -i $DISPLAY+$CAPTURECOORD -update 1 -frames:v 1 -vsync 0 -f image2 -compression_level $TIMELAPSE_PNG_COMPRESSION -q:v $TIMELAPSE_JPG_QUALITY "$TIMELAPSENAME$PROGRESSIVE.$TIMELAPSEEXT";
       FRAMENUM=$((FRAMENUM+1));
done
