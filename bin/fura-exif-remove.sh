#!/bin/bash -
source ~/.config/furayoshi/config.sh

if [ "$1" ]; then
    exiftool -overwrite_original -All= "$1" && \
	echo "removed metadata from $1"
else
    printf "${RED}ERR:${NC} no input file!\n"
fi
