#!/bin/bash -
FPS=10
SCALE=120:-1
ffmpeg -i $1 -vf "fps=$FPS,scale=$SCALE:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 $2.gif
