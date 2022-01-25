#!/bin/bash -
. ~/.config/furayoshi/ffmpeg/telegram-animation.sh
ffmpeg -an -i $1 \
       -crf $CRF -preset $PRESET \
       "${1%.*}$ENDING".mp4
