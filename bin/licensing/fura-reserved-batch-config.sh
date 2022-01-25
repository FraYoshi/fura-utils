#!/bin/bash -

# sourcing artist's variables
. ~/.config/furayoshi/licensing/artist.sh
. licensing.sh

# False for public domain
terms="True"
license="All Rights Reserved"
licenseLonger="$license"

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
			-xmp:Owner="$artist" \
			-XMP-dc:Title="$title" \
			-XMP-dc:Description="$description" \
			-XMP-dc:Rights="$licenseLonger" \
			-XMP-dc:Creator="$creator" \
			-xmp:LicensorEmail="$artistEmail" \
			-xmp:LicensorURL="$artistURL" \
			-xmp:CopyrightOwnerID="$artistISNI" \
			"$media"
	   done
	   echo "end of script"
	   break
	   ;;
   esac
done

# references https://wiki.creativecommons.org/wiki/Marking_Works_Technical
# XMP tags: https://exiftool.org/TagNames/XMP.html
