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

# read section
if [ $1 ]; then
    outDir="$1";
    echo "output set to $outDir"
else
    echo -e "dir to output to?\n(end with a slash './')"
    read ourDir
fi

# metadata assignment
echo -e "writing file with exif metadata to "$outDir"\nproceed?"
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
	       exiftool -P \
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
			"$media" -o "$outDir""$media"
	   done
	   echo "end of script"
	   break
	   ;;
   esac
done

# references https://wiki.creativecommons.org/wiki/Marking_Works_Technical
# XMP tags: https://exiftool.org/TagNames/XMP.html
