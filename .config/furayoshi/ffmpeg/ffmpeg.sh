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
set +a
