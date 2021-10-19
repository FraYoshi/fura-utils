#!/bin/bash -
if [ "$1" ] && [ "$2" ]; then
    oldExtension=$1
    newExtension=$2    
elif [ "$1" ] && [ "$2" != 0 ]; then
    oldExtension=$1
    echo "old extension set to $oldExtension"
    echo "input new extension:"
    read newExtension
else
    echo "input the extension to replace:"
    read oldExtension
    echo "input new extension:"
    read newExtension
fi
echo -en "coverting .$oldExtension to .$newExtension in "\""$PWD"\"" \nproceed?\n"
select yesno in yes no
do case $yesno in
       "no")
	   echo "abort"
	   break
	   ;;
       "yes")
	   find -type f -name "*.$oldExtension" \
	       | cut -c3- \
	       | while read media; \
	       do < /dev/null \
		    ffmpeg -i "$media" -c copy "${media%.*}.$newExtension" -y \
		       && touch -r "$media" "${media%.*}.$newExtension" \
		       && rm "$media"; \
	       done
	   echo "end of script"
	   break
	   ;;
   esac
done
