#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

echo "input the pattern to search and add, i.e. '*.mp4'"
read pattern

for f in $pattern; do
    echo "file '$f'" >> "$CONCATLIST";
done

echo "pattern is relative!"
