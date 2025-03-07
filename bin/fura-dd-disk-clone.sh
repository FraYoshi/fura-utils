#!/bin/sh -
source ~/.config/furayoshi/config.sh

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}Usage${NC}: $scriptName <input_file> <output_file> [block_size]"
    echo "Please specify the input and output files."
    exit 1
fi

# Assign the first two arguments to variables
ddif="$1"
ddof="$2"

# Check if the third argument is provided, otherwise use the default
if [ "$3" ]; then
  DDBS=$3
fi

dd if=$ddif of=$ddof bs=$DDBS conv=noerror,sync,notrunc iflag=fullblock oflag=sync status=progress
