#!/bin/bash -
source ~/.config/furayoshi/config.sh

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

exiftool -overwrite_original -All= "${1%.*}$PIC_HYPERCOMPRESS_SUFFIX.$PIC_HYPERCOMPRESS_FORMAT"

echo -en "file $1 saved as "\""${1%.*}$PIC_HYPERCOMPRESS_SUFFIX.$PIC_HYPERCOMPRESS_FORMAT"\""\n"
printf "${YELLOW}NOTICE:${NC} metadata has been removed too!\n"
