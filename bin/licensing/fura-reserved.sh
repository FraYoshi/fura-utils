#!/bin/bash -

# sourcing artist's variables
. ~/.config/furayoshi/licensing/artist.sh

# False for public domain
terms="True"
license="All Rights Reserved"
licenseLonger="$license"
contributors=""

## arguments list ##
# 1. file to add metadata to;
# 2. title of the opera;
# 3. (optional) description of the opera;

# colorizations
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# metadata assignment
if [ "$1" ]; then
    exiftool -overwrite_original -P \
	     -xmp:Marked="$terms" \
	     -xmp:UsageTerms="$licenseLonger" \
	     -xmp:Owner="$artist" \
	     -XMP-dc:Rights="$licenseLonger" \
	     -XMP-dc:Creator="$creator" \
	     -XMP-dc:Contributor="$contributors" \
	     -XMP-dc:Title="$2" \
	     -XMP-dc:Description="$3" \
	     -xmp:LicensorEmail="$artistEmail" \
	     -xmp:LicensorURL="$artistURL" \
	     -xmp:CopyrightOwnerID="$artistISNI" \
	     "$1"
else
    printf "${RED}ERR:${NC} no input file!\n"
fi

if [ -z "$2" ]; then
    printf "${YELLOW}NOTICE:${NC} no Title defined, can be added as second argument\n"
fi

if [ -z "$3" ]; then
    printf "${YELLOW}NOTICE:${NC} no Description defined, can be added as third argument\n"
fi
    
# date is preserved with -P
# references https://wiki.creativecommons.org/wiki/Marking_Works_Technical
# XMP tags: https://exiftool.org/TagNames/XMP.html
