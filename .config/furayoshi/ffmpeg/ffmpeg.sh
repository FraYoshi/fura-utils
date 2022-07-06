#!/bin/bash -
set -a

# CONCAT
CONCATLIST=concat-list.txt

# CUT
CUTSUFFIX=-cut

# GIF
GIFFPS=10
GIFSCALE=120:-1

# hyper-compress
HYPERSCALE=426x240
HYPEREXT=-ready
HYPERCRF=40
HYPERPRESET=placebo
HYPERFORMAT=mp4
HYPEROUTDIR=./

# audio 2opus
OPUSBITRATE=128k
OPUSVBR=1 #1 on, 0 off
OPUSCHANNELLAYOUT=stereo
OPUSEXT=opus # ogg is more compatible, opus is suggested.

# timelapse
TIMELAPSENAME=timelapse_
TIMELAPSEEXT=png
TIMELAPSERESOLUTION=1920X1080
CAPTURECOORD=

# FFV1
FFV1LEVEL=3
FFV1CONTEXT=0
FFV1GOP=1
FFV1THREADS=16
FFV1SLICES=4
FFV1SLICECRC=1
FFV1COLORSPACE=0
FFV1AUDIO=pcm_f32le
FFV1AUDIOHZ=48000
FFV1EXTENSION=mov
set +a
