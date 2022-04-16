#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

output="$1"

#FPS=10
#SCALE=120:-1

echo "from $CONCATLIST"
ffmpeg -f concat -safe 0 -i $CONCATLIST -vf "fps=$GIFFPS,scale=$GIFSCALE:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "$output".gif

echo "end of script"
