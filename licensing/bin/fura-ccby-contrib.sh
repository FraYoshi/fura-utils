#!/bin/bash -

# sourcing artist's variables
. ~/.config/furayoshi/licensing/artist.sh

# False for public domain
terms="1"
license="http://creativecommons.org/licenses/by/4.0/"
licenseLonger="This work is licensed to the public under the Creative Commons Attribution v4 license - $license"

echo "list all the contributors:"
read "contributors"

## arguments list ##
# 1. file to add metadata to;
# 2. title of the opera;
# 3. (optional) description of the opera;

# colorizations
RED='\033[0;31m'
NC='\033[0m' # No Color

# metadata assignment
if [ "$1" ] && [ "$2" ]; then
exiftool -overwrite_original -P \
	 -xmp:Marked="$terms" \
	 -xmp:UsageTerms="$licenseLonger" \
	 -xmp:Certificate="$license" \
	 -xmp:WebStatement="$license" \
	 -xmp:Owner="$artist" \
	 -XMP-dc:Rights="$licenseLonger" \
	 -XMP-dc:Creator="$creator" \
	 -XMP-dc:Contributor="$contributors" \
	 -XMP-dc:Title="$2" \
	 -XMP-dc:Description="$3" \
	 -XMP-cc:License="$license" \
	 -XMP-cc:AttributionName="$artist" \
	 -XMP-cc:AttributionURL="$artistURL" \
	 -XMP-cc:Requires="Attribution" \
	 -XMP-cc:Permits={"Derivative Works",Distribution,Reproduction,Sharing} \
	 "$1"
else
printf "${RED}ERR:${NC} a Title must be defined as second argument!\n"
fi
