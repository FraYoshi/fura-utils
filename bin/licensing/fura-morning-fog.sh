#!/bin/bash -

# sourcing artist's variables
. ~/.config/furayoshi/licensing/artist.sh

# False for public domain
terms="True"
license="http://creativecommons.org/licenses/by/4.0/"
licenseLonger="This work is licensed to the public under the Creative Commons Attribution v4 license - $license"

## arguments list ##
# 1. file to add metadata to;
# 2. title of the opera;
# 3. (optional) description of the opera;

# colorizations
RED='\033[0;31m'
NC='\033[0m' # No Color

# metadata assignment
echo -e "overwriting metadata on all the file in\n"$PWD"\nproceed?"
select yesno in yes no
do case $yesno in
       "no")
	   echo "abort"
	   break
	   ;;
       "yes")
	   echo "starting metadata injection"
	   find -type f -name "*" \
	       | cut -c3- \
	       | while read media; do
	       exiftool -overwrite_original -P \
			-xmp:Marked="$terms" \
			-xmp:UsageTerms="$licenseLonger" \
			-xmp:Certificate="https://www.safecreative.org/work/2105047739642-morning-fog-day-1" \
			-xmp:WebStatement="$license" \
			-xmp:Owner="$artist" \
			-xmp:LicensorEmail="$artistEmail" \
			-xmp:LicensorURL="$artistURL" \
			-xmp:CopyrightOwnerID="$artistISNI" \
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
			"$media"
	   done
	   echo "end of script"
	   break
	   ;;
   esac
done

# references https://wiki.creativecommons.org/wiki/Marking_Works_Technical
# XMP tags: https://exiftool.org/TagNames/XMP.html
