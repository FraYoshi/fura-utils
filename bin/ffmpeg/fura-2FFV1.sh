#!/bin/sh -
# reference: https://trac.ffmpeg.org/wiki/Encode/FFV1
# reference 2: https://www.youtube.com/watch?v=mIWD0oD9_pE
ffmpeg -i $1 \
       -c:v ffv1 -level 3
       -context 0 \
       -framerate $2 \
       -g 1 \
       -threads 16 \
       -slices 4 \
       -slicecrc 1 \
       -colorspace 1 \
       $3
# input example: frame-%04d.png
# out example: out.mov
# colorspace 0 is YCbCr ("YUV"); 1 is RGB
# GOP 1 for archival
# pix_fmt to select the bits per sample i.e. yuv422p10le
# context 0 (small - default) 1 (large) patterns - no golden rule
# more slices, more multi-threading - few bytes/slice of frame - more crc involved, more robust file
# -coder defaults to 0 if 8bit 1 if more. 2 is custom
