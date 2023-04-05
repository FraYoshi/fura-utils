#!/bin/bash -
source ~/.config/furayoshi/config.sh

if [ "$1" ] && [ $2 ]; then
    convert -resize $2 \
	    "$1" "${1%.*}$PIC_PREVIEWCOMPRESS_SUFFIX.$PIC_PREVIEWCOMPRESS_FORMAT"
elif
    [ "$1" ]; then
    convert -resize $PIC_PREVIEWCOMPRESS \
	    "$1" "${1%.*}$PIC_PREVIEWCOMPRESS_SUFFIX.$PIC_PREVIEWCOMPRESS_FORMAT"
else
    printf "${RED}ERR:${NC} no input file!\n"
fi
