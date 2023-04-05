#!/bin/bash -

# sourcing artist's variables
source ~/.config/furayoshi/config.sh

# colorizations
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# metadata assignment
if [ "$1" ] && [ $2 ]; then
    convert -resize $2 \
	    "$1" "${1%.*}$PIC_HYPERCOMPRESS_SUFFIX.$PIC_HYPERCOMPRESS_FORMAT"
elif
    [ "$1" ]; then
    convert -resize $PIC_HYPERCOMPRESS \
	    "$1" "${1%.*}$PIC_HYPERCOMPRESS_SUFFIX.$PIC_HYPERCOMPRESS_FORMAT"
else
    printf "${RED}ERR:${NC} no input file!\n"
fi
