#!/bin/bash -
source ~/.config/furayoshi/config.sh

if [ "$1" ]; then
    for pic in "$@"; do
	magick "$pic" "${pic%.*}.webp"
	touch -r "$pic" "${pic%.*}.webp"
        original_size=$(du -h "$pic" | cut -f1)
	new_size=$(du -h "${pic%.*}.webp" | cut -f1)
	printf "%s ${CYAN}original size: %s${NC}\n" "$pic" "$original_size"
	printf "%s ${GREEN}webp size: %s${NC}\n" "${pic%.*}.webp" "$new_size";
    done
else
    printf "${RED}ERR:${NC} no input file!\n"
fi
