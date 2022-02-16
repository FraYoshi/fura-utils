#!/bin/bash -

CRF=35
PRESET=placebo
SCALE=128:-1
FRAMERATE=12

ffmpeg -an -i $1 -vf "scale=$SCALE" -r $FRAMERATE -c:v libx265 -crf $CRF -preset $PRESET $2
