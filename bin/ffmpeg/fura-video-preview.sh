#!/bin/bash -

CRF=32
PRESET=veryslow
SCALE=120:-1

ffmpeg -i $1 -c:v libx265 -crf $CRF -preset $PRESET -s $SCALE $2.mov
