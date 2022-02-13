#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

FPS=10
SCALE=120:-1

echo "from $CONCATLIST"
ffmpeg -f concat -safe 0 -i $CONCATLIST -vf "fps=$FPS,scale=$SCALE:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 $1.gif
