#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

# $1 should be quoted

if [ "$1" ] && [ "$2" ]; then
    pattern="$1"
    output="$2"
elif
    [ "$1" ]; then
    pattern="$1"
    echo "input the export filename i.e. 'full-video.mkv'"
    read output
else
    echo "input the pattern to search and add, i.e. '*.mp4'"
    read pattern
    echo "input the export filename i.e. 'full-video.mkv'"
    read output
fi
    
for f in $pattern; do
    echo "file '$f'" >> "$CONCATLIST";
done

ffmpeg -f concat -safe 0 -i "$CONCATLIST" -c copy "$output"
