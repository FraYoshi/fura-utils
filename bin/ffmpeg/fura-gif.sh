#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

input="$1"

#FPS=10
#SCALE=120:-1
ffmpeg -i "$input" -vf "fps=$GIFFPS,scale=$GIFSCALE:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "${input%.*}".gif \
       && rouch -r "$input" "${input%.*}.gif"
echo "end of script"
