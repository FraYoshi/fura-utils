#!/bin/bash -

if [ "$1" ]; then
    if [ -d "$1" ]; then
	XZ_OPT=-e9 tar cJf "${1%/}".tar.xz "$1" \
	    && echo -en "directory "$1" saved as "${1%/}".tar.xz \n"
    else
	xz -9e -c "$1" > "$1".xz  \
	    && echo -en "file "$1" saved as "$1".xz \n"
    fi
else
    printf "${RED}ERR:${NC} no input file!\n"
fi
