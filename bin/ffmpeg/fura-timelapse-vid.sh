#!/bin/bash -

source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

## START of TEST CODE

if [[ -z $DISPLAY ]]; then
    echo  "input DISPLAY variable i.e. :0.0"
    read DISPLAY
fi

if [[ $1 ]]; then
    FPS=$1
else
    echo "input the fps (frame per second) to capture"
    read FPS
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
    TIMELAPSEVIDNAME=$3
elif
    [[ $TIMELAPSEVIDNAME ]]; then
    TIMELAPSEVIDNAME=$TIMELAPSEVIDNAME
else
    echo "input an output name i.e. timelapse_"
    read $TIMELAPSEVIDNAME
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

ffmpeg -hide_banner -video_size $TIMELAPSERESOLUTION -framerate $FPS -f x11grab -i $DISPLAY+$CAPTURECOORD -c:v $TIMELAPSEVIDCODEC -crf $TIMELAPSEVIDCRF -preset $TIMELAPSEVIDPRESET -vf setpts=N/FR/TB "$TIMELAPSEVIDNAME.$TIMELAPSEVIDEXT"

#more info at https://trac.ffmpeg.org/wiki/Capture/Desktop
