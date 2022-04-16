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
if (dialog --title "Confirmation" --yesno "coverting .$oldExtension to .$newExtension in "$PWD" proceed?" 10 35)
   then
       find -type f -name "*.$oldExtension" \
	   | cut -c3- \
	   | while read media; \
	   do < /dev/null \
		ffmpeg -i "$media" -c copy "${media%.*}.$newExtension" -y \
		   && touch -r "$media" "${media%.*}.$newExtension" \
		   && rm "$media";
       done
else
    echo "abort"
fi
