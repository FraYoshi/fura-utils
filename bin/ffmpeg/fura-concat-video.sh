#!/bin/bash -
source ~/.config/furayoshi/ffmpeg/ffmpeg.sh

echo "input the pattern to search and add, i.e. '*.mp4'"
read pattern
echo "input the export filename i.e. 'full-video.mkv'"
read output

for f in $pattern; do
    echo "file '$f'" >> "$CONCATLIST";
done

ffmpeg -f concat -safe 0 -i "$CONCATLIST" -c copy "$output"
