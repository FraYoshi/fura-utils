#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

echo "input the export filename i.e. 'full-video.mkv'"
read output

ffmpeg -f concat -safe 0 -i "$CONCATLIST" -c copy "$output"
