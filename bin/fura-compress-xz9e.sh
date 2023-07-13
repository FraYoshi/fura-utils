#!/bin/bash -

if [ "$1" ]; then
    xz -9e -c "$1" > "$1.xz"  \
    && echo -en "file "$1" saved as "$1.xz" \n"
else
    printf "${RED}ERR:${NC} no input file!\n"
fi